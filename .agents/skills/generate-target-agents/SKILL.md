---
name: generate-target-agents
description: "Translate source Claude Code agent files into a target client's custom agent format. Use when: converting agents to VS Code Copilot, Factory Droid, Kilo Code, or other targets; generating target agent files; migrating agents cross-platform; building field mappings from source to target format."
argument-hint: "Target client name or docs URL (e.g., 'VS Code Copilot', 'Factory Droid', 'Kilo Code')"
tools:
  - read
  - edit
  - search
  - command
  - fetch
---

# Generate Target Client Agents

Translate source agent files (Claude Code YAML frontmatter + markdown body) into a target client's custom agent format, then place them at the target's user-wide location.

## When to Use

- Converting `.source/agents/*.md` files to a new target client format
- Re-running a conversion after source agents have been updated
- Adding support for a new target client type
- Verifying or repairing a previous conversion

## Procedure

### 1. Detect Environment

Detect whether the source is being run from **Windows** or **Linux/WSL**. Record this as the target environment—target files will be placed at the target's user-wide location for this same environment.

### 2. Identify Source Files

Read all agent files from `.source/agents/`. Each file uses Claude Code format:
- YAML frontmatter with fields: `name`, `description`, `tools`, `model`, and optional `disallowedTools`, `permissionMode`, `skills`, `hooks`
- Markdown body containing the agent's system prompt

Reference: [Source agents README](./../.source/agents/instructions/list.md)

### 3. Discover Target Format

Given the target client name or docs URL:

1. **Check the learned target index first.** Look in [generate-target-agents.md](./../../generate-target-agents.md) under "Learned target type index" for a cached entry matching the target. If found, use that cached information and skip to step 4.
2. **If no cached entry exists, discover via web fetch.** Use web fetch tools to locate the target's documentation site **non-interactively** (do not ask the user for URLs). Search for and recursively follow documentation links to find the section on custom agents/sub-agents. Extract:
   - User-wide location (for both Windows and Linux/WSL when documented)
   - File format and extension
   - Valid config fields and which are required vs optional
   - File naming rules and conventions
3. **Cache the discovery.** Record the newly discovered target type as a new subsection in the "Learned target type index" of [generate-target-agents.md](./../../generate-target-agents.md), including the documentation URL, environment, and all extracted details. This prevents re-fetching on future runs.

### 4. Build Field Mapping

Create a mapping between each source field (frontmatter + body) and the most appropriate target field:

| Source (Claude Code) | Target | Transformation |
|----------------------|--------|----------------|
| `name` | *(target's name field)* | *(document rule)* |
| `description` | *(target's description field)* | *(document rule)* |
| `tools` | *(target's tool config)* | *(map tool names to target equivalents)* |
| `model` | *(target's model field)* | *(map model identifiers)* |
| Body (markdown) | *(target's prompt/body area)* | *(preserve verbatim)* |
| Unmapped fields | *(comments/extra metadata)* | *(document preservation strategy)* |

**CRITICAL:** The translation must be **lossless**—do not omit any information from the source file.

### 5. Generate Target Files

For each source agent file:

1. **Backup first.** Before modifying any existing target files, copy each to a timestamped backup (e.g., `<filename>.bak.20260301T1423`).
2. **Double-buffer edits.** Write to a `.tmp` file first. Only after verification, atomically replace the original (`Move-Item -Force` on Windows).
3. **Verify after swap.** Read back the target file and confirm it parses correctly. If verification fails, restore from backup immediately.

Place generated files at the target's **user-wide** location for the detected environment.

### 6. Generate Conversion Report

After completion, generate a conversion report directory at `docs/reports/<target>/` (e.g., `docs/reports/kilo-code/`, `docs/reports/factory-droid/`). This allows multiple report files per target if needed (e.g., separate field mapping docs, issue logs, or re-run reports).

The primary report file should contain:
- Target client name and date
- Source and target formats
- File list with target locations
- Field mapping table used
- Tool mapping details
- Any issues encountered and whether they were resolved

Reference existing reports for format: [docs/reports/](./../../docs/reports/)

## Known Target Types

The [generate-target-agents.md](./../../generate-target-agents.md) task guide maintains a "Learned target type index" that caches previously discovered target formats. Step 3 checks this cache first—if a matching entry exists, it is used directly without re-fetching docs. If no entry exists, the skill discovers the format via web fetch and then caches it for future runs.

## Quality Checks

- [ ] Every source agent has a corresponding target file
- [ ] All frontmatter fields are mapped or explicitly documented as preserved via alternative means
- [ ] Body text is preserved verbatim (lossless)
- [ ] Target files are at the correct user-wide location for the detected environment
- [ ] Backups exist for any overwritten files
- [ ] Conversion report is generated
