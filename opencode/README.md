# OpenCode config

Personal OpenCode configuration with custom agents, slash commands, and skills.

## Structure

- **`AGENTS.md`** — Global agent instructions (communication style, debugging principles, efficiency rules)
- **`agents/`** — Custom agent definitions (debug, thinker)
- **`commands/`** — Slash commands (commit-all, format-then-lint, review)
- **`skills/`** — Custom skills (good-programming-principles, token-efficiency-opencode)
- **`install.sh`** — Symlink installer for `~/.config/opencode`

## Agents

### Debug
**Mode:** All (primary + subagent)  
**Purpose:** Systematic debugging using root cause analysis

Read-only during investigation; implements fixes only after completing the four-phase debugging process. No shortcuts permitted.

### Thinker
**Mode:** Primary  
**Purpose:** Creative brainstorming and design thinking

Read-only agent for exploring ideas, proposing alternatives, and shaping designs before implementation. Asks questions one at a time.

## Commands

- **`/commit-all`** — Stage all changes and create a commit
- **`/format-then-lint`** — Run formatter followed by linter
- **`/review`** — Review code changes before committing

## Skills

- **`good-programming-principles`** — KISS, DRY, YAGNI, SOLID principles
- **`token-efficiency-opencode`** — Minimize token usage in file operations

## Resources

- [OpenCode Agents Documentation](https://opencode.ai/docs/agents/)
- [Systematic Debugging Skill by obra/superpowers](https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/systematic-debugging/SKILL.md)
- [Brainstorming Skill by obra/superpowers](https://skills.sh/obra/superpowers/brainstorming)

## Usage

Switch primary agents with **Tab** or invoke subagents with **@mention** (e.g., `@debug`). Use slash commands with `/command-name`.
