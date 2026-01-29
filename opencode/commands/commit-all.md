---
name: commit-all
description: Stage and commit all changes with a generated message
---

Run the following steps to stage and commit the code. If you want formatting and linting, run `/format-then-lint` first.

1.  **Stage Changes**:
    - Run `git add .` to stage all modified and untracked files.

2.  **Generate Commit**:
    - Analyze the staged changes (using `git diff --cached` if necessary to understand the context).
    - Draft a concise, descriptive commit message following the **Conventional Commits** specification (e.g., `feat: add search`, `fix: handle null url`).
    - Create the commit using `git commit -m "..."`.

3.  **Handle Pre-commit Hook Failures**:
    - If the commit fails due to pre-commit hooks (e.g., lint checks, formatting checks, tests):
      - Report the error output clearly to the user
      - Ask the user how they would like to proceed (e.g., fix the issues automatically, skip hooks, or abort)
    - Report all other errors or unexpected output to the user and ask for next steps.

4.  **Report**:
    - Output the result of the commit operation.
