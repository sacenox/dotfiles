---
name: commit-all
description: Format, lint, and commit all changes with a generated message
---

Run the following steps to clean and commit the code:

1.  **Detect Available Code Quality Tools**:
    - Examine the current project to identify available formatting and linting commands:
      - Check for `package.json`, `Makefile`, `pyproject.toml`, `Cargo.toml`, or other project configuration files
      - Look for common script names like `format`, `lint`, `check`, or similar
      - Identify the appropriate command runner (npm, bun, pnpm, make, cargo, poetry, etc.)
    - If no code quality tools are found, skip to step 3 (staging changes).

2.  **Run Code Quality Tools** (if available):
    - Execute the detected formatting command first (if available)
    - Then execute the detected linting command (if available)
    - If any command fails, stop immediately and report the issues.
    - If no commands are configured, skip this step gracefully.

3.  **Stage Changes**:
    - Run `git add .` to stage all modified and untracked files.

4.  **Generate Commit**:
    - Analyze the staged changes (using `git diff --cached` if necessary to understand the context).
    - Draft a concise, descriptive commit message following the **Conventional Commits** specification (e.g., `feat: add search`, `fix: handle null url`).
    - Create the commit using `git commit -m "..."`.

5.  **Handle Pre-commit Hook Failures**:
    - If the commit fails due to pre-commit hooks (e.g., lint checks, formatting checks, tests):
      - Report the error output clearly to the user
      - Ask the user how they would like to proceed (e.g., fix the issues automatically, skip hooks, or abort)
    - Report all other errors or unexpected output to the user and ask for next steps.

6.  **Report**:
    - Output the result of the commit operation, including which tools were run (if any).
    - If pre-commit hooks failed and were fixed, report what issues were resolved.
