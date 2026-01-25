# Generate Target Client Agents

Use the source custom agent files and translate them from the source format into the target's specific format, then add them to the target's custom agent location.

## Goal

Your goal is to create corresponding agent files in the target's format and place them at the target's user-wide custom agent location.

## Source agent files

Location: <./.source/agents/>  
Format: Claude Code (https://code.claude.com/docs/en/sub-agents#write-subagent-files)

## Target agent files location and format

Given the target (name/version or vendor docs URL), search the web for the target's documentation site. Once found, search for the section on custom agents/sub-agents. In that section you need to find:

1. Location: the user-wide location and directory name for its custom agent files (NOT local workspace directory)
2. File format, valid config fields, and file naming rules

After reading all of this information:

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

### Claude Code (subagents)

- Documentation URL: https://code.claude.com/docs/en/sub-agents
- User-wide location: `~/.claude/agents/` (available across all projects).
- Project-level location (for reference): `.claude/agents/` (project-specific, version-controlled).
- File format: Markdown file with YAML frontmatter followed by the system prompt body.
- Required frontmatter fields: `name`, `description`.
- Optional frontmatter fields: `tools`, `disallowedTools`, `model`, `permissionMode`, `skills`, `hooks`.
- Notes: the frontmatter defines subagent metadata and configuration; the body becomes the subagent’s system prompt. CLI-defined subagents can be provided via `--agents` JSON with `description`, `prompt`, `tools`, and `model` fields.
