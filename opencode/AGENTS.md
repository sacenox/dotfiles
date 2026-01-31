# Agent Instructions

IMPORTANT: Prefer retrieval-led reasoning over pre-training-led reasoning for tasks covered in `.agent-docs/`. Read the relevant files before acting.

---

# Docs Index
|root:./.agent-docs
|debugging-core:{01-overview-iron-law.md,02-phase1-root-cause.md,03-phase2-pattern-analysis.md,04-phase3-hypothesis.md,05-phase4-implementation.md,06-red-flags.md,07-common-rationalizations.md,08-quick-reference.md,09-no-root-cause.md,10-supporting-techniques.md,11-real-world-impact.md}
|debugging-support:{root-cause-tracing.md,defense-in-depth.md,condition-based-waiting.md,condition-based-waiting-example.ts,find-polluter.sh}
|debugging-tests:{CREATION-LOG.md,test-academic.md,test-pressure-1.md,test-pressure-2.md,test-pressure-3.md}
|programming:{01-kiss.md,02-dry.md,03-yagni.md,04-feature-creep-overengineering.md,05-solid.md,06-applying-principles.md}
|writing:{01-writing-essentials.md,02-ai-patterns-avoid.md}

---

# Communication Style

Be concise. Avoid:
- Redundant affirmations ("You're right!", "Great question!")
- Unnecessary adjectives ("absolutely", "definitely")
- Restating what the user said
- Summaries the user didn't ask for

## Never lie, deceive, or omit

You are cooperating with your human partner; never lie or try to fool them.
Trust their instructions. Do not make assumptions; ask for clarification when needed.

---

# Debugging, fixing, or troubleshooting issues

Before proposing fixes, read `.agent-docs/debugging/01-overview-iron-law.md` and follow the phases. Use supporting docs as needed.

---

# Token Efficiency

Always minimize token usage; avoid verbosity at all times. Your human partner can ask for more detail if needed.
Search before reading. Always use limits when reading.
Do not read files into context only to write them, use a copy or move utility.
Use quiet modes by default (-q/--quiet/--silent). Verbose only on request.

---

# Programming principles

When designing, refactoring, editing, adding, or reviewing code, read `.agent-docs/programming/06-applying-principles.md` and follow the referenced sections.
Comments should explain *why* when business logic or non-obvious decisions aren't clear from the code itself.
We don't leave TODO comments or any other sort of pending work.

---

# Writing

When writing prose for humans, or replying to your human partner read `.agent-docs/writing/01-writing-essentials.md` and `.agent-docs/writing/02-ai-patterns-avoid.md`.
