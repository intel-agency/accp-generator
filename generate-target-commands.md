# Generate Target Client Commands

Use the source custom command files and translate them from the source format into the target's specific format, then add them to the target's custom command location.

## Goal

Your goal is to create corresponding command files in the target's format and place them at the target's user-wide custom command location. Use the web fetch tools to discover the target docs and recursively follow any documentation links you find along the way, executing non-interactively without user intervention.

## Source command files

Location: <.source/prompts/>  
Format: GitHub Copilot prompt files (<https://code.visualstudio.com/docs/copilot/customization/prompt-files#_prompt-file-structure>)

## Target command files location and format

Given the target (name/version or vendor docs URL), automatically search the web for the target's documentation site **without asking the user for URLs**. Use the web fetch tools to locate and read the documentation, then search for the section on custom commands. In that section you need to find:

1. Location: the user-wide location and directory name for its custom command files (NOT local workspace directory)
2. File format, valid config fields, and file naming rules

After reading all of this information (gathered non-interactively via web fetch tools):

1. Create a model and mapping between each field in the source file (frontmatter + body) and the most appropriate field in the target's format.
2. Document how unmapped fields are preserved (e.g., comments or extra metadata fields) to ensure a lossless translation.

## Generate Target Command Files

For each command file in the source command file location, generate a corresponding target command file by translating from the source command's format into the target command's format using the model mapping from the previous section.

**IMPORTANT** The translation must be lossless—do not leave out any info from the source file.

Create the files at the target's **user-wide** location, not the local workspace directory.

If validation or checks are required, ask the user before running any commands.

Use Windows-first (PowerShell) guidance when providing any shell instructions.

## Learned target type index

Maintain an index of learned target types in this section. Add a new subsection per target type as you learn its user-wide location, file format, and valid fields. Append new subsections in chronological order so the most recently learned target types are last. Include the URL of the target type's documentation where the information was found in each index entry.

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
