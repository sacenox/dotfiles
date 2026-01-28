---
name: token-efficiency-opencode
description: Token optimization best practices for cost-effective agent usage.
version: 0.0.0
---

# Token Efficiency Expert

Token optimization strategies to minimize cost without sacrificing quality.

## Core Principle

**Default to these guidelines unless the user requests verbose output or full file contents.**

Default assumption: **Users prefer efficient, cost-effective assistance.**

**OpenCode environment:** Always use structured tools (`Read`, `Grep`, `Glob`, `Edit`, `Write`) instead of shell text utilities (`cat`, `grep`, `find`, `sed`, `awk`). Use bash only for actual terminal operations (git, npm, docker, etc.).

---

## Quick Reference Card

**Before ANY file operation, ask yourself:**

1. Can I use Task/explore for this codebase question?
2. Can I avoid streaming file contents?
3. Can I filter before reading?
4. Is a small, targeted read enough?
5. Does the user need full content?

**Default strategy:**
1. **Exploratory questions** → Use `Task(subagent_type="explore")`
2. **Specific files/patterns** → Use `Glob`/`Grep`/`Read(limit)` 
3. **Full reads** → Only when required or requested

**Common patterns:**
```bash
# Exploring codebase
Task(subagent_type="explore", prompt="How does auth work?")

# Finding files
Glob: "**/*.py"

# Searching content
Grep: "def my_function" (include="*.py")

# Reading strategically
Read: large_file.py (limit: 100)
Read: large_file.py (offset: 500, limit: 100)

# Editing (always read first)
Read: config.py
Edit: config.py (oldString="...", newString="...")
```

**Core motto: Use Task for exploration. Filter first. Read selectively. Summarize intelligently.**

---

## Token Optimization Rules

### 1. Use Task Tool for Codebase Exploration

**CRITICAL for OpenCode:** When exploring codebases to gather context or answer questions that aren't needle queries for specific files, **ALWAYS use the Task tool** with the explore agent.

This is OpenCode's most powerful token optimization - the explore agent handles all the searching, reading, and filtering internally, returning only relevant findings.

**When to use Task/explore (REQUIRED):**
- ✅ "How does X work in this codebase?"
- ✅ "Where are errors from Y handled?"
- ✅ "What is the structure of Z?"
- ✅ "How are API endpoints organized?"
- ✅ Any exploratory question requiring multiple rounds of searching
- ✅ Understanding unfamiliar codebases
- ✅ Finding patterns across multiple locations
- ✅ Questions that would require 3+ Grep/Read operations

```python
# ✅ DO: Use Task for exploration
Task(
    subagent_type="explore",
    description="Research auth handling",
    prompt="""Explore the codebase (thoroughness: medium).
Find how authentication is handled - auth flow, token storage, error handling.
Return file paths and key findings."""
)

# ❌ DON'T: Manual exploration (wastes tokens)
Grep: "auth" (include="*.py")
Read: file1.py
Read: file2.py
Grep: "token" (include="*.py")
Read: file3.py
# ... multiple rounds of search/read
```

**When to use direct tools instead:**
- ✅ "Read file at path X" → Use `Read` (you know exact location)
- ✅ "Find class Foo" → Use `Glob("**/foo.py")` or `Grep("class Foo")` (needle query)
- ✅ "Search for string in this specific file" → Use `Grep(pattern, path="file.py")`
- ✅ You already know the exact file from previous context

**Rule of thumb:** If the question would require you to search, then read, then search again, then read again → **Use Task/explore first.**

---

### 2. Use Parallel Tool Calls

**OpenCode optimization:** When calling multiple tools with no dependencies between them, make all calls in parallel by sending them in a single message.

```python
# ✅ Efficient - parallel execution (single message, multiple tools)
Read: src/config.py
Read: src/utils.py
Read: tests/test_main.py
# All three execute simultaneously

# ❌ Less efficient - sequential messages
# Message 1: Read: src/config.py
# Wait for result...
# Message 2: Read: src/utils.py
# Wait for result...
# Message 3: Read: tests/test_main.py
```

**When to use parallel:**
- Reading multiple independent files
- Running multiple independent bash commands
- Launching multiple Task agents
- Any operations where results don't depend on each other

**When to use sequential:**
- Later calls need data from earlier results
- Operations must complete in order (e.g., Read before Edit)
- One operation depends on success of another

---

### 3. Always Read Before Edit or Write

**OpenCode requirement:** You MUST use `Read` before `Edit` or `Write` on existing files. Attempting to edit without reading will fail.

This requirement actually **saves tokens** - it prevents blind edits that might fail due to incorrect assumptions about file content.

```python
# ✅ Correct workflow
Read: config.py
Edit: config.py (oldString="DEBUG = False", newString="DEBUG = True")

# ❌ Will fail - no prior Read
Edit: config.py (oldString="DEBUG = False", newString="DEBUG = True")

# ✅ Creating new files (no Read required)
Write: new_file.py (content="...")
```

**Why this saves tokens:**
- Prevents failed edits and retry loops
- Ensures you have correct context for oldString
- Catches files that don't exist or have different content than expected

---

### 4. Use Quiet/Minimal Output Modes

**For commands with `--quiet`, `--silent`, or `-q` flags:**

```bash
# ❌ DON'T: Use verbose mode by default
command --verbose

# ✅ DO: Use quiet mode by default
command --quiet
command -q
command --silent
```

**Common commands with quiet modes:**
- `git -q`, `curl -s`, `wget -q`, `make -s`
- custom scripts with `--quiet`

**When to use verbose:** Only when user explicitly asks for detailed output.

---

### 5. NEVER Read Entire Log Files

**Log files can be 50-200K tokens. ALWAYS filter before reading.**

```bash
# ❌ NEVER DO THIS:
Read: /var/log/application.log
Read: debug.log
Read: error.log

# ✅ ALWAYS DO ONE OF THESE:

# Option 1: Read only the end (most recent)
Read: /var/log/application.log (offset: 4900, limit: 100)

# Option 2: Filter for errors/warnings first
Grep: "(?i)error|fail|warning" (path="/var/log/application.log")
# Then read context around found lines:
Read: /var/log/application.log (offset: 850, limit: 30)

# Option 3: Specific time range (if timestamps present)
Grep: "2026-01-28" (path="/var/log/application.log")

# Option 4: Count occurrences first to gauge scope
Bash: rg -c "ERROR" /var/log/application.log
# Output: 245
# Now you know there are many errors, read a sample:
Read: /var/log/application.log (offset: 4950, limit: 50)
```

**Exceptions:** Read the full log only if the user explicitly requests it, filtered output lacks critical context, or the log is confirmed small (<1000 lines).

---

### 3. Check Lightweight Sources First

**Before reading large files, check if info is available in smaller sources:**

**For Git repositories:**
```bash
# ✅ Check status first (small output)
Bash: git status --short
Bash: git log --oneline -10

# ❌ Don't immediately read
Read: .git/logs/HEAD  # Can be large
```

**For Python/Node projects:**
```bash
# ✅ Check package info (small files)
Bash: jq '.dependencies' package.json
Read: requirements.txt (limit: 20)

# ❌ Don't immediately read
Read: node_modules/  # Huge directory
Read: venv/  # Large virtual environment
```

**For long-running processes:**
```bash
# ✅ Check process status
Bash: ps -eo pid,comm,pcpu,pmem --sort=-pcpu

# ❌ Don't read full logs immediately
Read: /var/log/syslog
```

---

### 4. Use Search Tools Instead of Reading Files

**When searching for specific content:**

```bash
# ❌ DON'T: Read file then manually search
Read: large_file.py  # 30K tokens
# Then manually look for "def my_function"

# ✅ DO: Use Grep/Search to find it
Grep: "def my_function" large_file.py
# Then read only the relevant section if needed
Read: large_file.py (offset: <line-5>, limit: 20)
```

**Advanced search usage:**
```bash
Grep: "TODO" path="src" include="*.py"
Grep: "(?i)error" path="." include="*.log"
Bash: rg -c "import" *.py
```

---

### 5. Read Files with Limits

**If you must read a file, use offset and limit parameters:**

```bash
# ✅ Read first 100 lines to understand structure
Read: large_file.py (limit: 100)

# ✅ Read specific section
Read: large_file.py (offset: 500, limit: 100)

# ✅ Read just the imports/header
Read: script.py (limit: 50)
```

**For very large files:**
```bash
# Check file size first
Bash: wc -l large_file.txt
# Output: 50000 lines

# Then read strategically
Read: large_file.txt (limit: 100)  # Beginning
Read: large_file.txt (offset: 1000, limit: 100)  # Specific middle section
```

**Large test outputs (example):**
```python
Read(file_path, limit=10)
Read(file_path, offset=140, limit=120)
Grep: "test_index" tool_test_output.json
```
Targeted reads typically save 90%+ tokens versus full reads.

---

### 6. Avoid Streaming File Content into the Model

**CRITICAL OPTIMIZATION:** Prefer operations that do not emit file contents to the model context. These are near-zero token cost and scale well.

#### Common Low-Token File Operations

Use non-streaming bash operations for simple file management:

```bash
# ✅ Copy/move/rename (no content streaming)
Bash: cp source_file.txt destination_file.txt
Bash: mv old_name.py new_name.py
Bash: rm temp_file.txt
Bash: mkdir -p src/components

# ✅ Append without reading
Bash: cat >> log.txt << 'EOF'
New log entry
EOF

# ✅ Count lines without reading
Bash: wc -l document.txt

# ✅ Check file size without reading
Bash: du -h large_file.csv
Bash: stat -c%s file.bin  # Size in bytes
```

#### Bulk Text Changes Across Multiple Files

**For simple find/replace across many files:**

```bash
# ✅ Pure textual replacement (no structure/logic needed)
Bash: find src -name "*.py" -exec sed -i 's/old_text/new_text/g' {} +

# ✅ Rename variables across files (simple text)
Bash: rg -l "oldVarName" src/ | xargs sed -i 's/oldVarName/newVarName/g'

# ❌ DON'T use Edit for many files (streams all content)
Read: file1.py
Edit: file1.py (...)
Read: file2.py
Edit: file2.py (...)
# ... for 50 files = massive token cost
```

#### When to Use Read/Edit Instead of sed

Use structured `Read`/`Edit` tools when:

1. **Code-aware changes needed** - Indentation, syntax structure matters
2. **Must validate before modifying** - Need to check current state
3. **Logic-dependent changes** - Change depends on surrounding code
4. **User wants to review** - Show what will change
5. **Complex replacements** - Multi-line, context-sensitive

```python
# ✅ Use Edit: Complex, code-aware change
Read: module.py
Edit: module.py (
    oldString="def old_function(x):\n    return x * 2",
    newString="def new_function(x: int) -> int:\n    return x * 2"
)

# ✅ Use sed: Simple text replacement across many files
Bash: find . -name "*.md" -exec sed -i 's/http:/https:/g' {} +
```

#### Decision Tree for File Changes

**Ask yourself:**
1. Is this pure text replacement? → **sed** (fastest, lowest tokens)
2. Do I need to see the content first? → **Read + Edit** (safe, validated)
3. Is it code structure change? → **Read + Edit** (preserves syntax)
4. Multiple files, simple text? → **sed/find** (scales well)
5. Few files, complex logic? → **Read + Edit** (accurate)

#### Find CSV Column Indices

```bash
# ✅ Extract and number header row (no full file read)
Bash: python - <<'PY'
import csv
with open('file.csv', newline='') as f:
    for i, name in enumerate(next(csv.reader(f)), start=1):
        print(i, name)
PY
```
Use this to locate columns in wide CSVs without reading data rows.

#### Python Data Filtering Pattern

Write filtered data to a new file (e.g., `data_filtered.csv`) to preserve the original and make verification easier.

#### Handling Shell Aliases in Python Scripts

`subprocess.run()` does not expand aliases; use a full executable path instead.

---

### Key Principle for File Operations

**Ask yourself first:**
1. Can this be done with structured tools (`Glob`, `Grep`, `Read`, `Edit`) or simple file ops (`cp`, `mv`)?
2. Is the change purely textual (not logic-dependent)?
3. Do I need to see the file content, or just modify it?

If answers are YES, YES, NO → **Use structured tools or non-streaming ops, not full reads**

---

### 7. Filter Command Output

**For commands that produce large output:**

```bash
# ❌ DON'T: Capture all output
Bash: find / -name "*.py"  # Could return 10,000+ files

# ✅ DO: Prefer structured tools or narrow scopes
Glob: "**/*.py" (path: "/specific/path")
Grep: "test" (path: ".", include: "*.py")

# ✅ DO: If you must use shell commands, scope tightly
Bash: ls -la /specific/path
Bash: tree -L 2 /specific/path
```

---

### 8. Efficient Todo Management

**Keep todos concise to minimize token usage:**

```python
# ✅ Concise, actionable todos
TodoWrite: [
    {"id": "1", "content": "Fix type error in auth.py:42", "status": "pending"},
    {"id": "2", "content": "Update API endpoint to v2", "status": "pending"},
    {"id": "3", "content": "Run tests and fix failures", "status": "pending"}
]

# ❌ Verbose todos waste tokens
TodoWrite: [
    {"id": "1", "content": "I need to carefully examine the type error that was discovered in the authentication module located in auth.py at line 42 and determine the root cause before implementing a fix", "status": "pending"}
]
```

**Best practices:**
- Keep todo content brief (5-10 words max)
- Include file:line references for specificity
- Update status immediately after completing tasks
- Don't batch completions - mark done as you go
- Only have ONE task "in_progress" at a time

**Token impact:** Concise todos save 50-70% tokens compared to verbose descriptions, especially on long task lists.

---

### 9. Summarize, Don't Dump

Summarize key facts and offer to drill down. Avoid pasting long raw outputs or full files unless requested.

Example:
"487 files total; key items: main.py, tests/, docs/. Want a specific file or type?"

---

### 9. Use Targeted Reads for Large Output

**When commands produce large output:**

```bash
# ✅ Limit output length with targeted reads
Read: large_file.txt (limit: 100)
Read: large_file.txt (offset: 900, limit: 100)

# ✅ Sample from middle
Read: large_file.txt (offset: 400, limit: 100)

# ✅ Check size before reading
Bash: wc -l file.txt
# If > 1000 lines, use small limits and offsets
```

---

### 10. Use JSON/Data Tools Efficiently

**For JSON, YAML, XML files:**

```bash
# ❌ DON'T: Read entire file
Read: large_config.json  # Could be 50K tokens

# ✅ DO: Extract specific fields
Bash: jq '.metadata' large_config.json
Bash: jq 'keys' large_config.json  # Just see top-level keys
Bash: yq '.database.host' config.yaml

# For XML
Bash: xmllint --xpath '//database/host' config.xml
```

**For CSV files:**
```bash
# ❌ DON'T: Read entire CSV
Read: large_data.csv  # Could be millions of rows

# ✅ DO: Sample and analyze
Read: large_data.csv (limit: 20)  # See header and sample rows
Bash: wc -l large_data.csv  # Count rows
Bash: csvstat large_data.csv  # Get statistics (if csvkit installed)
```

---

### 11. Optimize Code Reading

**For understanding codebases:**

```bash

# ✅ STEP 1: Get overview
Glob: "**/*.py" (path: ".")  # List files
Grep: "^class " (path: ".", include: "*.py")  # List classes
Bash: rg "^def " -g "*.py" -c  # Count functions per file

# ✅ STEP 2: Read structure only
Read: main.py (limit: 100)  # Just imports and main structure

# ✅ STEP 3: Search for specific code
Grep: "class MyClass" (path: "src", include: "*.py")

# ✅ STEP 4: Read only relevant sections
Read: src/mymodule.py (offset: 150, limit: 50)  # Just the relevant class

# ❌ DON'T: Read entire files sequentially
Read: file1.py  # 30K tokens
Read: file2.py  # 30K tokens
Read: file3.py  # 30K tokens
```

---

### 12. Efficient Scientific Literature Searches

Batch searches (3-5 at a time), group by taxonomy/topic, and save results after each batch. Track “not found” items to avoid repeats.

### Dealing with Session Interruptions

When limits are near, save progress, record what’s done/remaining, and write a resume file (e.g., `PROGRESS_YYYYMMDD.md`).

### Search Term Iteration

If searches fail, broaden terms systematically (species → genus → family). Avoid repeating the same query.

---

## Token Savings Examples

Use a short, filtered read instead of a full file:

```bash
Read: /var/log/app.log (offset: 2000, limit: 50)
Grep: "(?i)error|traceback" /var/log/app.log
```

This pattern typically saves 90%+ tokens versus full reads.

## When to Override These Guidelines

**Override efficiency rules when:**
1. User explicitly requests full output
2. Filtered output lacks necessary context
3. The file is small (<200 lines)
4. The user is in learning mode (understanding structure/patterns)

In cases 1-3, ask whether to proceed with a full read vs a filtered view. In learning mode, read a few key files fully, then return to efficient mode.

---

## Strategic File Selection for Learning Mode

When entering learning mode, **first determine if this is broad exploration or targeted learning**, then apply the appropriate strategy.

### Learning Mode Types

**Type 1: Broad Exploration** - "Help me understand this codebase", "How is this organized?"
→ Use repository-based strategies below (identify type, read key files)

**Type 2: Targeted Pattern Learning** - "How do I implement X?", "Show me examples of Y"
→ Use targeted concept search (see Targeted Pattern Learning section below)

---

## Targeted Pattern Learning

When user asks about a **specific technique or pattern**, use this focused approach instead of broad exploration.

**Opencode note:** Replace shell `grep/find/head` examples below with `Grep` and `Glob` calls, and use `Read` with limits for context.

### Examples of Targeted Learning Queries

- "How do variable number of outputs work in Galaxy wrappers?"
- "Show me how to fetch invocation data from Galaxy API"
- "How do I implement conditional parameters in Galaxy tools?"
- "How does error handling work in this codebase?"
- "Show me examples of async function patterns"
- "How are tests structured for workflow X?"

### Targeted Learning Workflow

1. Identify the concept and likely file types
2. Search for 2–3 relevant examples
3. Pick the simplest and most recent
4. Read those examples fully
5. Explain the pattern, variations, and pitfalls

Keep the search and read steps small; summarize before expanding.

---

### When to Use Targeted Learning

**Use targeted learning when user:**
 - ✅ Asks how to implement a specific feature or pattern

**Don't use for:**
 - ❌ Broad codebase overview or debugging requests

---

### Key Principles for Targeted Learning

Search first, read 2–3 examples, explain the pattern and pitfalls, then confirm what the user needs next.

---

## General Exploration vs Targeted Learning

**When user says → Use this approach:**

| User Request | Approach | Strategy |
|--------------|----------|----------|
| "Help me understand this codebase" | **General Exploration** | Identify repo type → Read key files |
| "How is this project organized?" | **General Exploration** | Read docs → Entry points → Architecture |
| "Show me how to implement X" | **Targeted Learning** | Search for X → Read examples → Extract pattern |
| "How does feature Y work?" | **Targeted Learning** | Grep for Y → Find best examples → Explain |
| "What patterns are used here?" | **General Exploration** | Read core files → Identify patterns |
| "How do I use API method Z?" | **Targeted Learning** | Search for Z usage → Show examples |

---

## Broad Repository Exploration

When entering broad exploration mode, **first identify the repository context**, then apply the appropriate exploration strategy.

**Opencode note:** Use `Glob` and `Grep` instead of `find/grep`, and `Read` with limits instead of `head/tail`.

### STEP 1: Identify Repository Type

Identify repo type quickly (library, monolith, framework, or examples), then read docs + 2–5 representative files.
Summarize patterns and ask where to go deeper.

---

### File Selection Priorities (General Rules)

Priorities (in order):
1. Documentation (README, CONTRIBUTING, architecture docs)
2. Entry points (main/app/run)
3. Core components (managers/orchestrators/base classes)
4. Representative examples (recent, medium complexity)
5. Active areas (recent commits)

Keep it to 2–5 files, then summarize and ask where to go deeper.

---

### Key Principle for Learning Mode

Read 2–5 key files, summarize patterns, then ask where to go deeper. Avoid reading many files without a plan.

---

## Cost Impact

Applying these rules often reduces token usage by 90%+.

### Real-World Token Savings Examples

**Example 1: Log File Analysis**
```bash
# ❌ BEFORE (inefficient approach):
Read: /var/log/application.log  # 50,000 lines = ~150,000 tokens

# ✅ AFTER (efficient approach):
Grep: "(?i)error" (path="/var/log/application.log")  # ~500 tokens
Read: /var/log/application.log (offset: 4950, limit: 50)  # ~1,500 tokens
# Total: ~2,000 tokens saved = 98.7% reduction
```

**Example 2: Codebase Exploration**
```bash
# ❌ BEFORE (manual exploration):
Grep: "auth" (include="*.py")  # ~3,000 tokens
Read: src/auth.py  # ~8,000 tokens
Read: src/middleware.py  # ~6,000 tokens
Grep: "token" (include="*.py")  # ~2,500 tokens
Read: src/token_handler.py  # ~5,000 tokens
# Total: ~24,500 tokens

# ✅ AFTER (using Task/explore):
Task(subagent_type="explore", prompt="How does auth work?")
# Returns summary in ~2,000 tokens
# Saved: ~22,500 tokens = 92% reduction
```

**Example 3: Multiple File Operations**
```bash
# ❌ BEFORE (sequential reads):
# Message 1: Read: config.py (~2,000 tokens)
# Message 2: Read: utils.py (~3,000 tokens)
# Message 3: Read: tests.py (~4,000 tokens)
# Total: ~9,000 tokens + 3 round trips

# ✅ AFTER (parallel calls):
# Single message with 3 parallel reads
Read: config.py
Read: utils.py
Read: tests.py
# Total: ~9,000 tokens + 1 round trip
# Saved: 2 round trips + reduced overhead = ~30% faster
```

**Example 4: Bulk Text Replacement**
```bash
# ❌ BEFORE (Edit tool for 50 files):
Read: file1.py + Edit: file1.py  # ~3,000 tokens × 50 files
# Total: ~150,000 tokens

# ✅ AFTER (sed for simple replacement):
Bash: find src -name "*.py" -exec sed -i 's/old/new/g' {} +
# Total: ~200 tokens
# Saved: ~149,800 tokens = 99.9% reduction
```

**Cumulative savings in typical session:**
- Without token-efficiency: ~200,000 tokens
- With token-efficiency: ~15,000 tokens
- **Total savings: 92.5%**

---

## Implementation

**This skill automatically applies these optimizations when:**
- Reading log files
- Executing commands with large output
- Navigating codebases
- Debugging errors
- Checking system status

**You can always override by saying:**
- "Show me the full output"
- "Read the entire file"
- "I want verbose mode"
- "Don't worry about tokens"

---

## Managing Long-Running Background Processes

### Best Practices for Background Tasks

Keep long-running jobs resumable: record PID/status, save progress, and write a resume note before ending a session.

---

## Repository Organization for Long Projects

Keep long projects tidy: use `python_scripts/`, `logs/`, and `tables/` so listing/searching stays small and focused. Organize early or once files start piling up.

---

## Summary

**Core motto: Use Task for exploration. Filter first. Read selectively. Summarize intelligently.**

**Primary optimization rules (highest impact):**
1. **Use Task/explore for codebase questions** - Handles all searching internally
2. **Avoid streaming file contents** - Prefer structured tools (Read/Grep/Glob/Edit) and non-streaming file ops (cp/mv/mkdir)
3. **Use parallel tool calls** - Call multiple independent tools in one message
4. **Always Read before Edit/Write** - Required by OpenCode, prevents failed edits

**Secondary rules:**
- Never read log files fully - filter first
- Use Grep before Read for targeted searches
- Read with limits (offset/limit parameters)
- Summarize instead of showing raw output
- Use quiet modes for commands (git -q, curl -s)
- Strategic file selection for learning mode

**Typical token savings: 90%+ in large tasks**

**Example workflow:**
```bash
# Exploration
Task(subagent_type="explore", prompt="How does auth work?")

# Targeted work
Grep: "class AuthHandler" (include="*.py")
Read: src/auth.py (offset: 100, limit: 50)
Edit: src/auth.py (oldString="...", newString="...")
```
