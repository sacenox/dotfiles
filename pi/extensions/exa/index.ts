import { mkdtemp, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { StringEnum } from "@earendil-works/pi-ai";
import {
	DEFAULT_MAX_BYTES,
	DEFAULT_MAX_LINES,
	formatSize,
	truncateHead,
	type ExtensionAPI,
	withFileMutationQueue,
} from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const EXA_MCP_URL =
	"https://mcp.exa.ai/mcp?tools=web_search_exa,web_fetch_exa";
const MCP_PROTOCOL_VERSION = "2025-06-18";
const DEFAULT_RATE_LIMIT_WAIT_MS = 1000;
const MAX_RATE_LIMIT_WAIT_MS = 5000;
const DEFAULT_CONTENTS_MAX_CHARACTERS = 3000;
const SEARCH_TYPES = [
	"auto",
	"fast",
	"instant",
	"deep-lite",
	"deep",
	"deep-reasoning",
] as const;

const SearchParams = Type.Object({
	query: Type.String({ description: "Natural-language web search query" }),
	type: Type.Optional(
		StringEnum(SEARCH_TYPES, {
			description: "Search depth and latency tradeoff (default: auto)",
		}),
	),
	numResults: Type.Optional(
		Type.Integer({
			minimum: 1,
			maximum: 10,
			description: "Number of results to return (default: 10)",
		}),
	),
});

const ContentsParams = Type.Object({
	urls: Type.Array(Type.String({ description: "A URL to read" }), {
		minItems: 1,
		maxItems: 10,
		description: "URLs to read (1-10). Batch multiple URLs in one call.",
	}),
	maxCharacters: Type.Optional(
		Type.Integer({
			minimum: 1,
			description: `Maximum characters to extract per page (default: ${DEFAULT_CONTENTS_MAX_CHARACTERS})`,
		}),
	),
});

interface JsonRpcResponse {
	jsonrpc: "2.0";
	id?: number;
	result?: unknown;
	error?: { code: number; message: string };
}

interface McpToolResult {
	content?: Array<{ type: string; text?: string }>;
	isError?: boolean;
}

interface McpCallOutcome {
	text: string;
	keyed: boolean;
	rateLimitRetries: number;
}

class McpError extends Error {
	readonly status: number | undefined;
	readonly rpcCode: number | undefined;
	readonly retryAfterMs: number | undefined;

	constructor(
		message: string,
		options?: {
			status?: number;
			rpcCode?: number;
			retryAfterMs?: number;
		},
	) {
		super(message);
		this.name = "McpError";
		this.status = options?.status;
		this.rpcCode = options?.rpcCode;
		this.retryAfterMs = options?.retryAfterMs;
	}
}

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isMcpToolResult(value: unknown): value is McpToolResult {
	if (!isRecord(value)) return false;
	if (value.content !== undefined) {
		if (!Array.isArray(value.content)) return false;
		if (
			!value.content.every(
				(block) =>
					isRecord(block) &&
					typeof block.type === "string" &&
					(block.text === undefined || typeof block.text === "string"),
			)
		) {
			return false;
		}
	}
	return value.isError === undefined || typeof value.isError === "boolean";
}

function apiError(body: string): string {
	try {
		const parsed: unknown = JSON.parse(body);
		if (isRecord(parsed)) {
			if (typeof parsed.error === "string") return parsed.error;
			if (
				isRecord(parsed.error) &&
				typeof parsed.error.message === "string"
			) {
				return parsed.error.message;
			}
		}
	} catch {
		// Fall back to the response body below.
	}
	return body.trim() || "Empty response";
}

function parseMcpResponse(
	body: string,
	contentType: string,
	requestId: number,
): JsonRpcResponse {
	const candidates = contentType.includes("text/event-stream")
		? body
				.split("\n")
				.filter((line) => line.startsWith("data:"))
				.map((line) => line.slice(5).trim())
		: [body];

	for (const candidate of candidates.reverse()) {
		if (!candidate || candidate === "[DONE]") continue;
		try {
			const parsed = JSON.parse(candidate) as JsonRpcResponse;
			if (parsed.jsonrpc === "2.0" && parsed.id === requestId) return parsed;
		} catch {
			// Ignore non-JSON SSE data and continue looking for our response.
		}
	}
	throw new Error("Exa MCP returned no matching JSON-RPC response");
}

function parseRetryAfterMs(header: string | null): number | undefined {
	if (!header) return undefined;
	const seconds = Number.parseFloat(header);
	if (!Number.isFinite(seconds) || seconds < 0) return undefined;
	return seconds * 1000;
}

function rateLimitWaitMs(error: unknown): number | undefined {
	if (!(error instanceof McpError)) return undefined;
	if (error.status === 429) {
		return error.retryAfterMs ?? DEFAULT_RATE_LIMIT_WAIT_MS;
	}
	// The server has returned code -32000 with a rate-limit message before;
	// catch it if it ever arrives wrapped in an HTTP 200. The message check
	// requires an HTTP or RPC signal, so tool-level content that mentions
	// "rate limit" does not trigger a paid retry.
	if (
		error.rpcCode === -32000 ||
		((error.status !== undefined || error.rpcCode !== undefined) &&
			/rate.?limit/i.test(error.message))
	) {
		return error.retryAfterMs ?? DEFAULT_RATE_LIMIT_WAIT_MS;
	}
	return undefined;
}

function sleep(ms: number, signal: AbortSignal | undefined): Promise<void> {
	return new Promise((resolve, reject) => {
		if (signal?.aborted) {
			reject(new Error("Aborted"));
			return;
		}
		const timer = setTimeout(() => {
			signal?.removeEventListener("abort", onAbort);
			resolve();
		}, ms);
		function onAbort() {
			clearTimeout(timer);
			reject(new Error("Aborted"));
		}
		signal?.addEventListener("abort", onAbort, { once: true });
	});
}

function mcpHeaders(apiKey: string | undefined): Record<string, string> {
	const headers: Record<string, string> = {
		"Content-Type": "application/json",
		Accept: "application/json, text/event-stream",
	};
	if (apiKey) headers["x-api-key"] = apiKey;
	return headers;
}

async function mcpRequest(
	endpoint: string,
	requestId: number,
	method: string,
	params: Record<string, unknown>,
	sessionId: string | undefined,
	apiKey: string | undefined,
	signal: AbortSignal | undefined,
): Promise<{ response: JsonRpcResponse; sessionId?: string }> {
	const headers = mcpHeaders(apiKey);
	if (sessionId) headers["Mcp-Session-Id"] = sessionId;

	const httpResponse = await fetch(endpoint, {
		method: "POST",
		headers,
		body: JSON.stringify({
			jsonrpc: "2.0",
			id: requestId,
			method,
			params,
		}),
		signal,
	});
	const body = await httpResponse.text();
	if (!httpResponse.ok) {
		throw new McpError(
			`Exa MCP failed (${httpResponse.status} ${httpResponse.statusText}): ${apiError(body)}`,
			{
				status: httpResponse.status,
				retryAfterMs: parseRetryAfterMs(
					httpResponse.headers.get("Retry-After"),
				),
			},
		);
	}

	const response = parseMcpResponse(
		body,
		httpResponse.headers.get("Content-Type") ?? "",
		requestId,
	);
	if (response.error) {
		throw new McpError(
			`Exa MCP error ${response.error.code}: ${response.error.message}`,
			{
				rpcCode: response.error.code,
				retryAfterMs: parseRetryAfterMs(
					httpResponse.headers.get("Retry-After"),
				),
			},
		);
	}
	return {
		response,
		sessionId:
			httpResponse.headers.get("Mcp-Session-Id") ?? sessionId ?? undefined,
	};
}

async function notifyMcpInitialized(
	endpoint: string,
	sessionId: string,
	apiKey: string | undefined,
	signal: AbortSignal | undefined,
): Promise<void> {
	const headers = mcpHeaders(apiKey);
	headers["Mcp-Session-Id"] = sessionId;

	const response = await fetch(endpoint, {
		method: "POST",
		headers,
		body: JSON.stringify({
			jsonrpc: "2.0",
			method: "notifications/initialized",
			params: {},
		}),
		signal,
	});
	const body = await response.text();
	if (!response.ok) {
		throw new McpError(
			`Exa MCP initialization failed (${response.status} ${response.statusText}): ${apiError(body)}`,
			{
				status: response.status,
				retryAfterMs: parseRetryAfterMs(
					response.headers.get("Retry-After"),
				),
			},
		);
	}
}

async function mcpToolCall(
	toolName: string,
	args: Record<string, unknown>,
	urlParams: Record<string, string>,
	apiKey: string | undefined,
	signal: AbortSignal | undefined,
): Promise<string> {
	const endpoint = new URL(EXA_MCP_URL);
	for (const [name, value] of Object.entries(urlParams)) {
		endpoint.searchParams.set(name, value);
	}

	const initialized = await mcpRequest(
		endpoint.toString(),
		1,
		"initialize",
		{
			protocolVersion: MCP_PROTOCOL_VERSION,
			capabilities: {},
			clientInfo: { name: "pi-exa-extension", version: "1.0.0" },
		},
		undefined,
		apiKey,
		signal,
	);
	if (!initialized.sessionId) {
		throw new Error("Exa MCP did not return a session ID");
	}
	await notifyMcpInitialized(
		endpoint.toString(),
		initialized.sessionId,
		apiKey,
		signal,
	);

	const called = await mcpRequest(
		endpoint.toString(),
		2,
		"tools/call",
		{ name: toolName, arguments: args },
		initialized.sessionId,
		apiKey,
		signal,
	);
	if (!isMcpToolResult(called.response.result)) {
		throw new Error("Exa MCP returned an invalid tool result");
	}
	const result = called.response.result;
	const text = (result.content ?? [])
		.filter(
			(block): block is { type: string; text: string } =>
				block.type === "text" && typeof block.text === "string",
		)
		.map((block) => block.text)
		.join("\n")
		.trim();
	if (result.isError) throw new McpError(text || "Exa MCP tool call failed");
	return text || "No results found.";
}

async function callMcpTool(
	toolName: string,
	args: Record<string, unknown>,
	urlParams: Record<string, string>,
	signal: AbortSignal | undefined,
): Promise<McpCallOutcome> {
	const apiKey = process.env.EXA_API_KEY?.trim() || undefined;
	if (!apiKey) {
		const text = await mcpToolCall(
			toolName,
			args,
			urlParams,
			undefined,
			signal,
		);
		return { text, keyed: false, rateLimitRetries: 0 };
	}

	// Prefer the free anonymous tier. On a rate limit, wait and retry once,
	// then fall back to the API key. Other errors and keyed failures surface
	// without further fallbacks.
	let rateLimitRetries = 0;
	for (;;) {
		try {
			const text = await mcpToolCall(
				toolName,
				args,
				urlParams,
				undefined,
				signal,
			);
			return { text, keyed: false, rateLimitRetries };
		} catch (error) {
			const waitMs = rateLimitWaitMs(error);
			if (waitMs === undefined) throw error;
			rateLimitRetries += 1;
			if (rateLimitRetries > 1) break;
			await sleep(Math.min(waitMs, MAX_RATE_LIMIT_WAIT_MS), signal);
		}
	}
	const text = await mcpToolCall(toolName, args, urlParams, apiKey, signal);
	return { text, keyed: true, rateLimitRetries };
}

async function buildToolOutput(
	output: string,
): Promise<{ text: string; fullOutputPath?: string }> {
	const truncation = truncateHead(output, {
		maxLines: DEFAULT_MAX_LINES,
		maxBytes: DEFAULT_MAX_BYTES,
	});
	let text = truncation.content;
	let fullOutputPath: string | undefined;

	if (truncation.truncated) {
		const directory = await mkdtemp(path.join(tmpdir(), "pi-exa-"));
		const tempFile = path.join(directory, "results.txt");
		fullOutputPath = tempFile;
		await withFileMutationQueue(tempFile, () =>
			writeFile(tempFile, output, "utf8"),
		);
		text += `\n\n[Output truncated: showing ${truncation.outputLines} of ${truncation.totalLines} lines (${formatSize(truncation.outputBytes)} of ${formatSize(truncation.totalBytes)}). Full output saved to: ${fullOutputPath}]`;
	}
	return { text, fullOutputPath };
}

export default function exaExtension(pi: ExtensionAPI): void {
	pi.registerTool({
		name: "exa_search",
		label: "Exa Search",
		description: `Search the web with Exa and return URLs plus relevant highlights. Output is truncated to ${DEFAULT_MAX_LINES} lines or ${formatSize(DEFAULT_MAX_BYTES)}. Uses Exa's free hosted MCP service; EXA_API_KEY is optional and only used as a rate-limit fallback.`,
		promptSnippet:
			"Search the web with Exa and return relevant excerpts and source URLs",
		promptGuidelines: [
			"Use exa_search for current information and web research, and cite the returned source URLs in the answer.",
		],
		parameters: SearchParams,
		async execute(_toolCallId, params, signal) {
			const searchType = params.type ?? "auto";
			const result = await callMcpTool(
				"web_search_exa",
				{ query: params.query, numResults: params.numResults ?? 10 },
				{ defaultSearchType: searchType },
				signal,
			);
			const { text, fullOutputPath } = await buildToolOutput(result.text);
			return {
				content: [{ type: "text", text }],
				details: {
					keyed: result.keyed,
					rateLimitRetries: result.rateLimitRetries,
					requestedSearchType: searchType,
					fullOutputPath,
				},
			};
		},
	});

	pi.registerTool({
		name: "exa_contents",
		label: "Exa Contents",
		description:
			"Read the full content of web pages as clean markdown with Exa, when you know the URLs.",
		promptSnippet: "Read full web page content for known URLs with Exa",
		promptGuidelines: [
			"Use exa_contents to read the full content of pages whose URLs you know.",
		],
		parameters: ContentsParams,
		async execute(_toolCallId, params, signal) {
			const result = await callMcpTool(
				"web_fetch_exa",
				{
					urls: params.urls,
					maxCharacters:
						params.maxCharacters ?? DEFAULT_CONTENTS_MAX_CHARACTERS,
				},
				{},
				signal,
			);
			const { text, fullOutputPath } = await buildToolOutput(result.text);
			return {
				content: [{ type: "text", text }],
				details: {
					keyed: result.keyed,
					rateLimitRetries: result.rateLimitRetries,
					urlCount: params.urls.length,
					fullOutputPath,
				},
			};
		},
	});
}
