# Generate Target Client Commands

Use the source custom command files and translate them from the source format into the target's specific format, then add them to the target's custom command location.

## Goal

Your goal is to create corresponding command files in the target's format and place them at the target's user-wide custom command location in the **same environment as the source**. First detect whether the source is being run from **Windows** or **Linux/WSL**, record that as the target environment, and then use the target's user-wide location for that same environment. Use the web fetch tools to discover the target docs and recursively follow any documentation links you find along the way, executing non-interactively without user intervention.

## Source command files

Location: <.source/prompts/>  
Format: GitHub Copilot prompt files (<https://code.visualstudio.com/docs/copilot/customization/prompt-files#_prompt-file-structure>)

## Target command files location and format

Given the target (name/version or vendor docs URL), automatically search the web for the target's documentation site **without asking the user for URLs**. Use the web fetch tools to locate and read the documentation, then search for the section on custom commands. In that section you need to find:

0. Environment-specific locations: determine and record the target's user-wide location for **Windows** and for **Linux/WSL** when both are documented.
1. Location: the user-wide location and directory name for its custom command files (NOT local workspace directory)
2. File format, valid config fields, and file naming rules

After reading all of this information (gathered non-interactively via web fetch tools):

1. Create a model and mapping between each field in the source file (frontmatter + body) and the most appropriate field in the target's format.
2. Document how unmapped fields are preserved (e.g., comments or extra metadata fields) to ensure a lossless translation.

## Generate Target Command Files

For each command file in the source command file location, generate a corresponding target command file by translating from the source command's format into the target command's format using the model mapping from the previous section.

**IMPORTANT** The translation must be lossless—do not leave out any info from the source file.

**CRITICAL — Backup and safe-write procedure:**

1. **Backup first.** Before making any changes, copy each target file (or the entire target directory) to a timestamped backup (e.g., `<filename>.bak.20260301T1423`). Never modify the original without a backup in place.
2. **Double-buffer edits.** Copy the target file to a temporary working file (e.g., `<filename>.tmp` in the same directory). Apply all changes to the temp copy. Only after the temp copy is verified correct, atomically replace the original with the temp copy (e.g., `Move-Item -Force` on Windows). This prevents a half-written or corrupt file if the process is interrupted.
3. **Verify after swap.** After the swap, read back the target file and confirm it parses correctly. If verification fails, restore from the backup immediately.

Create the files at the target's **user-wide** location in the **same environment as the source** (Windows source -> Windows target location, Linux/WSL source -> Linux/WSL target location), not the local workspace directory.

If validation or checks are required, ask the user before running any commands.

Use Windows-first (PowerShell) guidance when providing any shell instructions.

## Learned target type index

Maintain an index of learned target types in this section. Add a new subsection per target type as you learn its user-wide location, file format, and valid fields. Append new subsections in chronological order so the most recently learned target types are last. Include the URL of the target type's documentation where the information was found in each index entry.

Record the **environment** for each learned entry (`Windows` or `Linux/WSL`). If paths differ by environment, create separate entries for the same target type (for example, one Windows entry and one Linux/WSL entry) rather than collapsing them into a single path.

### Claude Code (skills/commands)

- Documentation URL: <https://code.claude.com/docs/en/skills>
- User-wide location (skills): `~/.claude/skills/<skill-name>/SKILL.md`.
- Project-level location (skills): `.claude/skills/<skill-name>/SKILL.md`.
- User-wide legacy commands location (still supported): `~/.claude/commands/`.
- Project-level legacy commands location (still supported): `.claude/commands/`.
- File format (skills): `SKILL.md` with YAML frontmatter followed by Markdown body text.
- File format (legacy commands): Markdown file with the same YAML frontmatter fields as skills; each file creates a `/command`.
- Frontmatter fields: `name`, `description`, `argument-hint`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `context`, `agent`, `hooks`.
- Naming rules: skill `name` uses lowercase letters, numbers, and hyphens (max 64 chars); if `name` is omitted, Claude uses the directory name.

### Factory (custom slash commands)

- Documentation URL: <https://docs.factory.ai/cli/configuration/custom-slash-commands>
- User-wide location: `~/.factory/commands/`.
- Project-level location: `.factory/commands/`.
- File format: Markdown commands with optional YAML frontmatter (`description`, `argument-hint`, `allowed-tools` reserved) followed by body text; executable commands supported when file starts with a shebang.
- Naming rules: filenames are slugged to `/command` (lowercase, spaces → `-`, non-URL-safe characters dropped); top-level files only, nested folders ignored.
- Notes: `$ARGUMENTS` expands to chat input after the command name; Markdown commands render into a system notification for the next turn.

### Codex CLI (custom prompts and skills mirror)

- Documentation URL (custom prompts): <https://developers.openai.com/codex/cli/custom-prompts>
- Documentation URL (skills): <https://developers.openai.com/codex/cli/skills>
- User-wide location (custom prompts): `~/.codex/prompts/`.
- Project-level location (custom prompts): `.codex/prompts/`.
- User-wide location (skills): `~/.codex/skills/<skill-name>/SKILL.md`.
- Project-level location (skills): `.codex/skills/<skill-name>/SKILL.md`.
- File format (custom prompts): Markdown file; optional YAML frontmatter supports `description` and `argument-hint`.
- File format (skills): `SKILL.md` with YAML frontmatter and Markdown body.
- Required fields (skills): `name`, `description`.
- Optional fields (skills): `model`, `tools` (only when values are compatible with Codex skill metadata expectations).
- Naming rules (custom prompts): top-level `.md` files only; filename becomes command name under `/prompts:<filename-without-.md>`.
- Naming rules (skills): `name` must match `^[a-z0-9-]{1,64}$`; for converted prompts, use slug + deterministic hash when the source stem is invalid or collides.
- Notes: custom prompts are deprecated in favor of skills, but still supported. For lossless conversion, preserve source-only fields (`mode`, source-specific `tools`, unknown keys) in a metadata comment block in generated files.

### OpenCode CLI (custom commands)

- Documentation URL (commands): <https://opencode.ai/docs/commands/>
- Documentation URL (config): <https://opencode.ai/docs/config/>
- User-wide location: `~/.config/opencode/commands/`.
- Project-level location: `.opencode/commands/`.
- File format: Markdown file with optional YAML frontmatter followed by body text (template).
- Frontmatter fields: `description`, `agent`, `model`, `subtask`.
- Body features: `$ARGUMENTS` expands to chat input after command name; `$1`–`$N` positional arguments; `@file` includes file content; `!command` injects shell output.
- Naming rules: filename (without `.md`) becomes the slash command name (e.g., `test.md` → `/test`); top-level files only in the commands directory.
- Config alternative: commands can also be defined in `opencode.json` under the `command` key with `template`, `description`, `agent`, `model`, and `subtask` fields.
- Notes: custom commands override built-in commands if they share the same name. For lossless conversion from Copilot prompt files, preserve source-only fields (`mode`, `tools`, `name`, `argument-hint`, unknown keys) in an HTML comment block (`<!-- copilot-source: ... -->`) at the bottom of each generated file.
