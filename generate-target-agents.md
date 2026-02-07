# Generate Target Client Agents

Use the source custom agent files and translate them from the source format into the target's specific format, then add them to the target's custom agent location.

## Goal

Your goal is to create corresponding agent files in the target's format and place them at the target's user-wide custom agent location. Use the web fetch tools to discover the target docs and recursively follow any documentation links you find along the way, executing non-interactively without user intervention.

## Source agent files

Location: <./.source/agents/>  
Format: Claude Code (https://code.claude.com/docs/en/sub-agents#write-subagent-files)

## Target agent files location and format

Given the target (name/version or vendor docs URL), automatically search the web for the target's documentation site **without asking the user for URLs**. Use the web fetch tools to locate and read the documentation, then search for the section on custom agents/sub-agents. In that section you need to find:

1. Location: the user-wide location and directory name for its custom agent files (NOT local workspace directory)
2. File format, valid config fields, and file naming rules

After reading all of this information (gathered non-interactively via web fetch tools):

1. Create a model and mapping between each field in the source file (frontmatter + body) and the most appropriate field in the target's format.
2. Document how unmapped fields are preserved (e.g., comments or extra metadata fields) to ensure a lossless translation.

## Generate Target Agent Files

For each agent file in the source agent file location, generate a corresponding target agent file by translating from the source agent's format into the target agent's format using the model mapping from the previous section.

**IMPORTANT** The translation must be lossless—do not leave out any info from the source file.

Create the files at the target's **user-wide** location, not the local workspace directory.

If validation or checks are required, ask the user before running any commands.

Use Windows-first (PowerShell) guidance when providing any shell instructions.

## Learned target type index

Maintain an index of learned target types in this section. Add a new subsection per target type as you learn its user-wide location, file format, and valid fields. Append new subsections in chronological order so the most recently learned target types are last. Include the URL of the target type's documentation where the information was found in each index entry.

## Conclusion

After each run , generate a markdown report detailing the conversion process. Include a list of generated files, the locations you used, and a summary of the oncversion process you used. Also include any issus you faced and whther you overcamew them or they stystill ill p[ersisy.]

### Claude Code (subagents)

- Documentation URL: https://code.claude.com/docs/en/sub-agents
- User-wide location: `~/.claude/agents/` (available across all projects).
- Project-level location (for reference): `.claude/agents/` (project-specific, version-controlled).
- File format: Markdown file with YAML frontmatter followed by the system prompt body.
- Required frontmatter fields: `name`, `description`.
- Optional frontmatter fields: `tools`, `disallowedTools`, `model`, `permissionMode`, `skills`, `hooks`.
- Notes: the frontmatter defines subagent metadata and configuration; the body becomes the subagent’s system prompt. CLI-defined subagents can be provided via `--agents` JSON with `description`, `prompt`, `tools`, and `model` fields.

### Factory (custom droids)

- Documentation URL: https://docs.factory.ai/cli/configuration/custom-droids
- User-wide location: `~/.factory/droids/`.
- Project-level location: `.factory/droids/`.
- File format: Markdown with YAML frontmatter followed by the prompt body; body must be non-empty.
- Required frontmatter fields: `name` (lowercase letters, digits, hyphens, underscores; drives filename/`subagent_type`).
- Optional frontmatter fields: `description`, `model` (`inherit` or explicit model ID), `reasoningEffort` (e.g., low/medium/high), `tools` (omit for all tools; use category string like `read-only` or an array of tool IDs such as `Read`, `LS`, `Grep`, `Glob`, `Edit`, `Create`, `ApplyPatch`, `Execute`, `WebSearch`, `FetchUrl`; `TodoWrite` is auto-included).
- Naming rules: top-level `.md` files only; CLI normalizes filenames to lowercase, hyphenated slugs.
- Notes: project droids override personal droids on name conflicts; validator flags unknown models/tools.

### Kilo Code (custom modes)

- Documentation URL: https://kilo.ai/docs/customize/custom-modes
- User-wide location: `~/.kilo/` (Windows: `C:\Users\{username}\.kilo\`).
- Project-level location: `.kilocodemodes` (YAML or JSON file in workspace root).
- File format: YAML (preferred) or JSON configuration file with custom mode definitions.
- Main config file: `custom_modes.yaml` (global user-wide) or `.kilocodemodes` (project-level).
- Required fields: `slug` (unique identifier, pattern `/^[a-zA-Z0-9-]+$/`), `name` (display name), `description` (user-friendly summary), `roleDefinition` (core identity for system prompt), `groups` (tool access array).
- Optional fields: `whenToUse` (guidance for automated mode selection), `customInstructions` (additional behavioral guidelines), `model` (AI model override, defaults to `inherit`).
- Tool groups: `"read"`, `"edit"`, `"command"`, `"browser"`, `"mcp"`.
- File restrictions: Use tuple format `["edit", { fileRegex: "pattern", description: "text" }]` for edit group restrictions.
- Mode-specific instructions: Preferred method is directory-based at `~/.kilo/rules-{slug}/` (global) or `.kilo/rules-{slug}/` (project). Fallback is single file `.kilorules-{slug}`.
- Naming rules: Slugs must be lowercase letters, numbers, and hyphens only. Names support spaces and emojis for UI display.
- Notes: YAML uses single backslash escaping for regex (e.g., `\.md$`); JSON requires double backslash (e.g., `\\.md$`). Project modes override global modes with same slug. Can override built-in modes by using matching slugs. Instruction files are read recursively in alphabetical order.
