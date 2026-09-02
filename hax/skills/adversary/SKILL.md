# Adversary review

Delegate a focused, read-only adversarial review to an isolated hax process running a
different model.

## When to use

- The user asks for an adversarial, skeptical, or independent review of work.
- The work is significant enough (a changeset, a design, a plan) to justify a second,
  isolated pass with different eyes.

## How to run

1. Build a **review brief** containing, in prose:

   - the intended behavior and requirements;
   - the scope of the change (files, commands, tests involved);
   - any constraints or repository practices the review should check against;
   - pointers to the relevant context (paths) the reviewer should inspect.

   The reviewer does not have this conversation's context, so everything it needs to
   evaluate the change must be in the brief or reachable from the working directory.

2. Run it with:

   ```sh
   hax-adversary "$BRIEF"
   ```

   or, for a long brief, pipe it:

   ```sh
   cat <<'EOF' | hax-adversary
   <review brief>
   EOF
   ```

   `hax-adversary` is a wrapper around `hax -p --preset=adversary --no-session --bare`.
   The preset (in `~/.config/hax/config.json`) fixes the reviewer model and injects the
   reviewer instructions; `--bare` strips project instructions, skills, and subagent
   guidance so the reviewer sees only the brief and the repository.

3. Report the findings to the user, citing the exact code locations the reviewer gives.

## Notes

- The reviewer is instructed to be read-only and it runs with tools in a bare context,
  but there is no hard tool restriction — treat its output as findings to verify, not
  as a gate.
- A review may take a while: if the command detaches into a background task, wait on it
  and collect the output before reporting.