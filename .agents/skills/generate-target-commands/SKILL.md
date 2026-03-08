---
name: generate-target-commands
description: "Translate source Copilot prompt files into a target client's custom command/skill format. Use when: converting prompts to Claude Code skills, Factory Droid commands, OpenCode commands, Codex CLI prompts, or other targets; generating target command files; migrating commands cross-platform; building field mappings from source to target format."
argument-hint: "Target client name or docs URL (e.g., 'Claude Code', 'Factory Droid', 'OpenCode', 'Codex CLI')"
tools:
  - read
  - edit
  - search
  - command
  - fetch
---

# Generate Target Client Commands

Translate source command/prompt files (VS Code Copilot prompt format: YAML frontmatter + markdown body) into a target client's custom command or skill format, then place them at the target's user-wide location.

## When to Use

- Converting `.source/prompts/*.prompt.md` files to a new target client format
- Re-running a conversion after source prompts have been updated
- Adding support for a new target client type
- Verifying or repairing a previous conversion

## Procedure

### 1. Detect Environment

Detect whether the source is being run from **Windows** or **Linux/WSL**. Record this as the target environment — target files will be placed at the target's user-wide location for this same environment.

### 2. Identify Source Files

Read all prompt files from `.source/prompts/` (hardcoded per repo convention — update here if the repo restructures).

Each file uses VS Code Copilot prompt format:

- YAML frontmatter with metadata fields (see below)
- Markdown body containing the prompt/command instructions

**Known source frontmatter fields:**

| Field | Required | Description |
|---|---|---|
| `name` | Yes | Human-readable command name |
| `description` | Yes | Short description of what the command does |
| `argument-hint` | No | Placeholder text shown in the argument input |
| `mode` | No | Agent mode to use (e.g., `agent`, `edit`, `ask`) |
| `tools` | No | List of tool names the command may invoke |
| `model` | No | Preferred model for this command |
| `user-invocable` | No | Whether the user can trigger this command directly |
| `disable-model-invocation` | No | Whether to prevent model from auto-invoking |

For the latest field reference, see [VS Code Copilot prompt file docs](https://code.visualstudio.com/docs/copilot/chat/prompt-files).

If a source file has malformed frontmatter or cannot be parsed, **skip it**, log the error, and continue with the remaining files. Include skipped files and error details in the conversion report.

Reference: [Source prompts directory](../../../.source/prompts/)

### 3. Discover Target Format

Given the target client name or docs URL:

1. **Check the learned target index first.** Look in [generate-target-commands.md](../../../generate-target-commands.md) under "Learned target type index" for a cached entry matching the target. If found, use that cached information and skip to step 4.
2. **If no cached entry exists, discover via web fetch.** Use web fetch tools to locate the target's documentation site **non-interactively** (do not ask the user for URLs). Search for and recursively follow documentation links to find the section on custom commands, slash commands, or skills. Extract:
   - User-wide location (for both Windows and Linux/WSL when documented)
   - File format and extension
   - Valid config fields and which are required vs optional
   - File naming rules and conventions
   - Whether the target uses commands, skills, or both (and which is preferred/recommended)
   - **Variable syntax conventions:** how the target handles variable interpolation (e.g., `$ARGUMENTS`, `$1`–`$N` positional args, `@file` includes, `!command` injection), so step 4 can map source variables correctly
3. **Cache the discovery.** Record the newly discovered target type as a new subsection in the "Learned target type index" of [generate-target-commands.md](../../../generate-target-commands.md), including the documentation URL, environment, and all extracted details. This prevents re-fetching on future runs.

**If web fetch fails** (rate limited, docs moved, site down), **stop the entire run** — the target format is a hard dependency. Report the failure clearly with the URL attempted and the error received.

**Format selection (commands vs skills):** If the target supports both commands and skills:

1. **For re-runs:** Check whether the target location already has existing commands, skills, or both. Inform the user: *"This target has existing [commands/skills/both]. Do you want to generate commands, skills, or both?"*
2. **For first runs:** Ask the user which format(s) they want: commands, skills, or both.
3. **If the user doesn't know or has no preference:** default to **commands** (the simpler, more widely supported format).
4. Generate only the selected format(s). Document in the conversion report which format(s) were generated and note the alternative format(s) available for the target.

### 4. Build Field Mapping

Create a mapping between each source field (frontmatter + body) and the most appropriate target field:

| Source (Copilot Prompt) | Target | Transformation |
|-------------------------|--------|----------------|
| `name` | *(target's name/slug field)* | *(document rule, incl. naming constraints)* |
| `description` | *(target's description field)* | *(document rule)* |
| `argument-hint` | *(target's argument hint field)* | *(document rule)* |
| `mode` | *(target's mode/agent field)* | *(map mode names)* |
| `tools` | *(target's tool config)* | *(map tool names to target equivalents)* |
| Body (markdown) | *(target's prompt/body/template area)* | *(preserve content; adapt variable syntax if needed)* |
| Unmapped fields | *(comments/extra metadata)* | *(document preservation strategy)* |

**CRITICAL: Lossless translation.** All source information must appear in the target output. Where the target format's structure differs from the source (e.g., body becomes a `template` field, or the file becomes a `SKILL.md` inside a directory), the *information* is preserved even if the *structure* changes. Use these priority tiers:

- **Required (must appear):** `name`/slug, `description`, body/prompt content.
- **Best-effort (map if target supports):** `argument-hint`, `tools`, `mode` (mapped to target equivalents).
- **Document-only (preserve as comments or in report):** Fields with no target equivalent. Add as comments in the target file (e.g., HTML comment block `<!-- copilot-source: ... -->`) or document in the conversion report.

**Variable syntax adaptation:** If the source uses `$ARGUMENTS` or other variable interpolation, map to the target's equivalent syntax as discovered in step 3 (e.g., `$ARGUMENTS` for Factory/OpenCode, positional `$1`–`$N` for OpenCode, no built-in variables for Claude Code skills). Document syntactic transformations in the field mapping.

### 5. Generate Target Files

For each source prompt file:

1. **Backup first.** Before modifying any existing target files, copy each to a timestamped backup (e.g., `<filename>.bak.20260301T1423`).
2. **Double-buffer edits.** Write to a `.tmp` file first. Only after verification, atomically replace the original (`Move-Item -Force` on Windows).
3. **Verify after swap.** Read back the target file and run these checks:
   - YAML/frontmatter parses without errors (if target uses frontmatter)
   - All required fields (per target format from step 3) are present
   - Field values satisfy target naming rules (e.g., slug format, allowed characters)
   - Body/template content is non-empty
   - File extension and location match target convention
   - If target uses directory-based skills (e.g., Claude Code), the `SKILL.md` exists inside a correctly named directory. Default to a **single `SKILL.md`** per directory containing all content from the source prompt; splitting into subdirectories (`references/`, `scripts/`) is an optimization the user can request separately.
   If verification fails, restore from backup immediately.

**Re-run behavior:** If target files already exist from a prior conversion, overwrite them unconditionally (the backup in substep 1 protects against data loss). Include a diff summary of what changed in the conversion report.

Place generated files at the target's **user-wide** location for the detected environment.

### 6. Generate Conversion Report

After completion, generate a conversion report directory at `docs/reports/<target>/` (e.g., `docs/reports/factory-droid-commands/`, `docs/reports/claude-code-skills/`). This allows multiple report files per target if needed.

The primary report file is always named `conversion-report.md`. It should contain:

- Target client name and date
- Source and target formats
- File list with target locations
- Field mapping table used
- Variable syntax transformations applied
- Format selection rationale (commands vs skills vs both, and what already existed at target)
- Diff summary of changes (for re-runs over existing files)
- Skipped source files and errors (if any)
- Any other issues encountered and whether they were resolved

Reference existing reports for format: [docs/reports/](../../../docs/reports/)

### 7. Quality Gate

Run these checks before considering the conversion complete. If any check fails, fix the issue before finishing.

- [ ] Every source prompt has a corresponding target file (or is logged as skipped with reason)
- [ ] Required fields (`name`/slug, `description`, body content) are present in every target file
- [ ] Best-effort fields (`argument-hint`, `tools`, `mode`) are mapped where the target supports them
- [ ] Unmappable fields are preserved as comments in target files or documented in the report
- [ ] Variable syntax (e.g., `$ARGUMENTS`) is correctly adapted to target's equivalent per step 3 discovery
- [ ] Format selection (commands/skills/both) was confirmed with the user (or defaulted to commands)
- [ ] Target files are at the correct user-wide location for the detected environment
- [ ] Backups exist for any overwritten files
- [ ] Conversion report exists at `docs/reports/<target>/conversion-report.md`
- [ ] Report includes diff summary (for re-runs) and skipped file errors (if any)

## Known Target Types

The [generate-target-commands.md](../../../generate-target-commands.md) task guide maintains a "Learned target type index" that caches previously discovered target formats. Step 3 checks this cache first — if a matching entry exists, it is used directly without re-fetching docs. If no entry exists, the skill discovers the format via web fetch and then caches it for future runs.
