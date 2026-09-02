import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import type { AssistantMessage, Usage } from "@earendil-works/pi-ai";
import {
	type ExtensionAPI,
	getPackageDir,
	parseFrontmatter,
	RpcClient,
} from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const TIMEOUT_MS = 30 * 60 * 1_000;
const THINKING_LEVELS = [
	"off",
	"minimal",
	"low",
	"medium",
	"high",
	"xhigh",
	"max",
] as const;

type ThinkingLevel = (typeof THINKING_LEVELS)[number];
type ProgressUpdate = (text: string, details: Record<string, unknown>) => void;

interface AdversaryConfig {
	model: string;
	thinking: ThinkingLevel;
	systemPrompt: string;
}

const extensionPath = fileURLToPath(import.meta.url);
const promptPath = path.join(path.dirname(extensionPath), "adversary.md");

const AdversaryParams = Type.Object({
	task: Type.String({
		description:
			"Review brief containing the intended behavior, scope, constraints, and relevant context from the main conversation",
	}),
});

async function loadAdversaryConfig(): Promise<AdversaryConfig> {
	const content = await readFile(promptPath, "utf8");
	const { frontmatter, body } =
		parseFrontmatter<Record<string, unknown>>(content);
	const model =
		typeof frontmatter.model === "string" ? frontmatter.model.trim() : "";
	const thinking = frontmatter.thinking;

	if (!model) {
		throw new Error(
			`${promptPath} must declare a non-empty "model" in its frontmatter`,
		);
	}
	if (
		typeof thinking !== "string" ||
		!THINKING_LEVELS.includes(thinking as ThinkingLevel)
	) {
		throw new Error(
			`${promptPath} must declare "thinking" as one of: ${THINKING_LEVELS.join(", ")}`,
		);
	}
	if (!body.trim()) {
		throw new Error(
			`${promptPath} must contain reviewer instructions after its frontmatter`,
		);
	}

	return {
		model,
		thinking: thinking as ThinkingLevel,
		systemPrompt: body.trim(),
	};
}

function compactAction(value: unknown, maxLength = 120): string {
	const text =
		typeof value === "string"
			? value.replace(/\s+/g, " ").trim()
			: JSON.stringify(value);
	if (!text) return "";
	return text.length > maxLength ? `${text.slice(0, maxLength - 1)}…` : text;
}

function describeToolAction(toolName: string, args: unknown): string {
	if (args && typeof args === "object") {
		const input = args as Record<string, unknown>;
		if (toolName === "bash" && typeof input.command === "string") {
			return `${toolName}: ${compactAction(input.command)}`;
		}
		if (toolName === "read" && typeof input.path === "string") {
			return `${toolName}: ${compactAction(input.path)}`;
		}
	}
	const detail = compactAction(args);
	return detail && detail !== "{}" ? `${toolName}: ${detail}` : toolName;
}

function emptyUsage(): Usage {
	return {
		input: 0,
		output: 0,
		cacheRead: 0,
		cacheWrite: 0,
		totalTokens: 0,
		cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
	};
}

function addUsage(total: Usage, next: Usage): void {
	total.input += next.input;
	total.output += next.output;
	total.cacheRead += next.cacheRead;
	total.cacheWrite += next.cacheWrite;
	total.totalTokens += next.totalTokens;
	total.cost.input += next.cost.input;
	total.cost.output += next.cost.output;
	total.cost.cacheRead += next.cost.cacheRead;
	total.cost.cacheWrite += next.cost.cacheWrite;
	total.cost.total += next.cost.total;
	if (next.cacheWrite1h !== undefined) {
		total.cacheWrite1h = (total.cacheWrite1h ?? 0) + next.cacheWrite1h;
	}
	if (next.reasoning !== undefined) {
		total.reasoning = (total.reasoning ?? 0) + next.reasoning;
	}
}

function finalText(messages: AssistantMessage[]): string {
	for (let index = messages.length - 1; index >= 0; index--) {
		const text = messages[index]?.content
			.filter(
				(part): part is { type: "text"; text: string } => part.type === "text",
			)
			.map((part) => part.text)
			.join("\n")
			.trim();
		if (text) return text;
	}
	return "";
}

async function runAdversary(
	task: string,
	cwd: string,
	signal?: AbortSignal,
	onProgress?: ProgressUpdate,
) {
	const config = await loadAdversaryConfig();
	const client = new RpcClient({
		cliPath: path.join(getPackageDir(), "dist", "cli.js"),
		cwd,
		model: config.model,
		args: [
			"--no-session",
			"--no-skills",
			"--no-prompt-templates",
			"--no-extensions",
			"--tools",
			"read,grep,find,ls,bash",
			"--thinking",
			config.thinking,
			"--append-system-prompt",
			config.systemPrompt,
		],
	});
	const abort = () => void client.abort().catch(() => undefined);
	let unsubscribe: (() => void) | undefined;

	try {
		if (signal?.aborted) throw new Error("Adversarial review aborted");
		onProgress?.("Adversary is starting…", {
			model: config.model,
			thinking: config.thinking,
			status: "starting",
		});
		await client.start();
		signal?.addEventListener("abort", abort, { once: true });
		unsubscribe = client.onEvent((event) => {
			if (event.type === "tool_execution_start") {
				const action = describeToolAction(event.toolName, event.args);
				onProgress?.(action, {
					model: config.model,
					thinking: config.thinking,
					status: "running",
					action,
				});
			} else if (
				event.type === "message_update" &&
				event.assistantMessageEvent.type === "text_start"
			) {
				onProgress?.("Adversary is working...", {
					model: config.model,
					thinking: config.thinking,
					status: "writing",
				});
			}
		});
		const events = await client.promptAndWait(
			task,
			undefined,
			TIMEOUT_MS,
		);

		const messages: AssistantMessage[] = [];
		const usage = emptyUsage();
		for (const event of events) {
			if (event.type !== "message_end" || event.message.role !== "assistant")
				continue;
			messages.push(event.message);
			addUsage(usage, event.message.usage);
		}

		const last = messages[messages.length - 1];
		if (!last) throw new Error("Adversary returned no response");
		if (last.stopReason === "error" || last.stopReason === "aborted") {
			throw new Error(
				last.errorMessage || `Adversary stopped: ${last.stopReason}`,
			);
		}

		return {
			text: finalText(messages) || "No findings.",
			usage,
			turns: messages.length,
			model: config.model,
			thinking: config.thinking,
		};
	} finally {
		unsubscribe?.();
		signal?.removeEventListener("abort", abort);
		await client.stop();
	}
}

export default function adversaryExtension(pi: ExtensionAPI): void {
	pi.registerTool({
		name: "adversary_review",
		label: "Adversary Review",
		description:
			"Delegate a focused, read-only adversarial review.",
		promptSnippet:
			"Run a read-only adversarial review in an isolated reviewer context",
		promptGuidelines: [
			"Use adversary_review only when the user asks for an adversarial or independent review; include the intended behavior and constraints in its task.",
		],
		parameters: AdversaryParams,
		async execute(_toolCallId, params, signal, onUpdate, ctx) {
			const result = await runAdversary(
				params.task,
				ctx.cwd,
				signal,
				(text, details) => {
					onUpdate?.({ content: [{ type: "text", text }], details });
				},
			);
			return {
				content: [{ type: "text", text: result.text }],
				details: {
					model: result.model,
					thinking: result.thinking,
					turns: result.turns,
				},
				usage: result.usage,
			};
		},
	});
}
