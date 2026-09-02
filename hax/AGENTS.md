# Rules for AGENTS

- Always return exactly what was asked. Do not add scope, backwards compatibility or extras without the user explicitly asking.
- Use `gh` for Github (it's already authenticated as me).
- Use `uvx hf` for HuggingFace (also already authenticated as me).
- Use `curl` and the environment's `EXA_API_KEY` to search and read web contents.

## Golden rule for coding

> Bugs, Cyclomatic complexity, Time complexity, and Memory complexity are all directly related to the single lines of code amount.
> Less code, less complexity, less bugs.
