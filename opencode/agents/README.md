# OpenCode Agents

Custom agents for specialized workflows.

## Agents

### Debug
**Mode:** All (primary + subagent)  
**Purpose:** Systematic debugging using root cause analysis

Read-only during investigation phases, can implement fixes after completing the four-phase debugging process. Enforces no fixes without root cause investigation.

### Thinker
**Mode:** Primary  
**Purpose:** Creative brainstorming and design thinking

Read-only agent for exploring ideas, proposing alternatives, and shaping designs before implementation. Asks questions one at a time and validates designs incrementally.

## Resources

These agents were built using principles from:

- [OpenCode Agents Documentation](https://opencode.ai/docs/agents/)
- [Systematic Debugging Skill by obra/superpowers](https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/systematic-debugging/SKILL.md)
- [Brainstorming Skill by obra/superpowers](https://skills.sh/obra/superpowers/brainstorming)

## Usage

Switch between primary agents using **Tab** or invoke subagents with **@mention** (e.g., `@debug`).
