# Implementer / adversary loop

Delegate a unit of work to an isolated implementer, then an isolated adversarial
review. This session stays the overseer: it writes the task, calls the loop, and
audits the result with the user.

## When to use

- The user asks to use this workflow, the implementer/adversary loop, or `hax-loop`.
- The user describes a goal, feature, or change and wants it implemented that way
  rather than in this session.

## How to run

1. Stay the overseer. Do not implement the work yourself. Do not ask a subagent
   in this session to do it either.

2. Write the **task** in prose: intended behavior, scope, constraints, and any
   paths that matter. Pass it **verbatim**. Do not have another model restate it
   from the repository — that is how a wrong GOAL.md becomes the spec again.

3. From the project directory:

   ```sh
   hax-loop "$TASK"
   ```

   or, for a long task, pipe it:

   ```sh
   cat <<'EOF' | hax-loop
   <task>
   EOF
   ```

   `hax-loop` runs `hax -p --preset=implementer`, prints `git status` / `git diff`,
   then `hax -p --preset=adversary --bare`. Presets live in `~/.config/hax/config.json`.
   The implementer is launched without skills or subagent guidance so it cannot
   see this workflow. Nested `hax-loop` is refused.

4. Report the diff and the review to the user. Audit with them. If the generation
   is wrong, call `hax-loop` again with a corrected task. Do not auto-retry until
   the review is empty.

## Notes

- Never call `hax-loop` from an implementer or reviewer.
- The task is the requirement; repository docs constrain how, they do not replace
  the task.
- A loop run may take a while: if the command detaches into a background task,
  wait on it and collect the output before reporting.
