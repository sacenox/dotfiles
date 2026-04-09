# AGENTS.md

## Instruction fidelity

When the user asks for a specific change, do exactly that and nothing more.

- Do not add extra configuration, defaults, compatibility flags, optimizations, or behavioral changes unless the user explicitly asks for them.
- Do not infer "helpful" additions beyond the request.
- If a change seems advisable but was not requested, ask first instead of doing it.
- Prefer the minimal implementation that satisfies the user's stated request.
- If the user asks for only one model / one setting / one change, configure only that.

This is the default behavior.

## Web search with Exa HTTP API (via curl)

Use the `EXA_API_KEY` environment variable and call Exa directly with `curl`.

### Basic search

```bash
curl -sS https://api.exa.ai/search \
  -H "x-api-key: $EXA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"your query","numResults":5}'
```

### Include page text in results

```bash
curl -sS https://api.exa.ai/search \
  -H "x-api-key: $EXA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"your query","numResults":5,"contents":{"text":true}}'
```

### Notes

- Use `-sS` for clean output with visible errors.
- Add `-w "\nHTTP_STATUS:%{http_code}\n"` when you want an explicit status code.
- The API key must be sent in the `x-api-key` header.
