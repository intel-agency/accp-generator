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

Read all agent files from `.source/agents/` (hardcoded per repo convention — update here if the repo restructures).

Each file uses Claude Code format:

- YAML frontmatter with fields: `name`, `description`, `tools`, `model`, and optional `disallowedTools`, `permissionMode`, `skills`, `hooks`
- Markdown body containing the agent's system prompt

If a source file has malformed frontmatter or cannot be parsed, **skip it**, log the error, and continue with the remaining files. Include skipped files and error details in the conversion report.

Reference: [Source agents README](../../../.source/agents/instructions/list.md)

### 3. Discover Target Format

Given the target client name or docs URL:

1. **Check the learned target index first.** Look in [generate-target-agents.md](../../../generate-target-agents.md) under "Learned target type index" for a cached entry matching the target. If found, use that cached information and skip to step 4.
2. **If no cached entry exists, discover via web fetch.** Use web fetch tools to locate the target's documentation site **non-interactively** (do not ask the user for URLs). Search for and recursively follow documentation links to find the section on custom agents/sub-agents. Extract:
   - User-wide location (for both Windows and Linux/WSL when documented)
   - File format and extension
   - Valid config fields and which are required vs optional
   - File naming rules and conventions
3. **Cache the discovery.** Record the newly discovered target type as a new subsection in the "Learned target type index" of [generate-target-agents.md](../../../generate-target-agents.md), including the documentation URL, environment, and all extracted details. This prevents re-fetching on future runs.

**If web fetch fails** (rate limited, docs moved, site down), **stop the entire run** — the target format is a hard dependency. Report the failure clearly with the URL attempted and the error received.

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

**CRITICAL: Lossless translation.** All source information must appear in the target output. Where the target format's structure differs from the source (e.g., body content moves into a YAML field like `roleDefinition`), the *information* is preserved even if the *structure* changes. Use these priority tiers:

- **Required (must appear):** `name`, `description`, body/prompt content.
- **Best-effort (map if target supports):** `tools` (mapped to target equivalents), `model` (mapped to target identifiers).
- **Document-only (preserve as comments or in report):** Fields with no target equivalent (e.g., `permissionMode`, `hooks`). Add as comments in the target file or document in the conversion report.

### 5. Generate Target Files

For each source agent file:

1. **Backup first.** Before modifying any existing target files, copy each to a timestamped backup (e.g., `<filename>.bak.20260301T1423`).
2. **Double-buffer edits.** Write to a `.tmp` file first. Only after verification, atomically replace the original (`Move-Item -Force` on Windows).
3. **Verify after swap.** Read back the target file and run these checks:
   - YAML/JSON frontmatter parses without errors
   - All required fields (per target format from step 3) are present
   - Field values satisfy target naming rules (e.g., slug regex, allowed characters)
   - Body/prompt content is non-empty (unless target explicitly allows empty)
   - File extension matches target convention
   If verification fails, restore from backup immediately.

**Re-run behavior:** If target files already exist from a prior conversion, overwrite them unconditionally (the backup in substep 1 protects against data loss). Include a diff summary of what changed in the conversion report.

Place generated files at the target's **user-wide** location for the detected environment.

### 6. Generate Conversion Report

After completion, generate a conversion report directory at `docs/reports/<target>/` (e.g., `docs/reports/kilo-code/`, `docs/reports/factory-droid/`). This allows multiple report files per target if needed (e.g., separate field mapping docs, issue logs, or re-run reports).

The primary report file is always named `conversion-report.md` (e.g., `docs/reports/kilo-code/conversion-report.md`). It should contain:

- Target client name and date
- Source and target formats
- File list with target locations
- Field mapping table used
- Tool mapping details
- Diff summary of changes (for re-runs over existing files)
- Skipped source files and errors (if any)
- Any other issues encountered and whether they were resolved

Reference existing reports for format: [docs/reports/](../../../docs/reports/)

## Known Target Types

The [generate-target-agents.md](../../../generate-target-agents.md) task guide maintains a "Learned target type index" that caches previously discovered target formats. Step 3 checks this cache first—if a matching entry exists, it is used directly without re-fetching docs. If no entry exists, the skill discovers the format via web fetch and then caches it for future runs.

### 7. Quality Gate

Run these checks before considering the conversion complete. If any check fails, fix the issue before finishing.

- [ ] Every source agent has a corresponding target file (or is logged as skipped with reason)
- [ ] Required fields (`name`, `description`, body content) are present in every target file
- [ ] Best-effort fields (`tools`, `model`) are mapped where the target supports them
- [ ] Unmappable fields are preserved as comments in target files or documented in the report
- [ ] Target files are at the correct user-wide location for the detected environment
- [ ] Backups exist for any overwritten files
- [ ] Conversion report exists at `docs/reports/<target>/conversion-report.md`
- [ ] Report includes diff summary (for re-runs) and skipped file errors (if any)
