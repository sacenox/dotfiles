# OpenCode config

Personal OpenCode configuration with custom agents and slash commands.

## Structure

- **`AGENTS.md`** — Global agent instructions
- **`agents/`** — Custom agent definitions (debug, plan, writer)
- **`commands/`** — Slash commands (commit-all, format-then-lint, review)
- **`install.sh`** — Symlink installer for `~/.config/opencode`

## Agents

### Debug
**Mode:** Primary  
**Purpose:** Systematic debugging using root cause analysis

Enforces a four-phase debugging process and requires TodoWrite tracking. No fixes before root cause analysis.

### Plan
**Mode:** Primary  
**Purpose:** Read-only planning and design

Read-only agent for scoping work, comparing approaches, and writing plans to `.opencode/plans` before implementation.

### Writer
**Mode:** Subagent  
**Purpose:** Personal, informal blog post drafts

Writes ~500 word markdown posts from topics or provided resources, and always includes a Sources section.

## Commands

- **`/commit-all`** — Stage all changes and create a commit
- **`/format-then-lint`** — Run formatter followed by linter
- **`/review`** — Review code changes before committing

## Resources

- [OpenCode Agents Documentation](https://opencode.ai/docs/agents/)

## Usage

Switch primary agents with **Tab** or invoke subagents with **@mention** (e.g., `@debug`). Use slash commands with `/command-name`.
