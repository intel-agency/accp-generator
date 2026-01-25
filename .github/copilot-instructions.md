# accp-generator Copilot Instructions

## Project purpose
- This repo is a generator for translating **source agent/prompt files** into a target client’s custom agents/commands format.
- Source of truth:
  - Claude Code agents: `.source/agents/*.md` (YAML frontmatter + body).
  - Copilot prompt files: `.source/prompts/*.prompt.md` (YAML frontmatter + body).
- Task guides: `generate-target-agents.md` and `generate-target-commands.md`.

## Key patterns to follow
- **Lossless translations:** preserve every field and body text from the source files; do not omit content.
- **Frontmatter-driven metadata:** source files rely on YAML frontmatter. Keep metadata intact when mapping to target fields.
- **Windows-first shell guidance:** repo conventions assume Windows + PowerShell (see `.source/README.md`). Avoid bash-only commands.

## Target-generation workflow (core repo behavior)
When asked to generate target agents/commands:
1. Read target vendor docs to find **user-wide** location, file format, and valid config fields.
2. Build a clear field mapping from source → target (document in response if needed).
3. Generate target files from `.source/agents` or `.source/prompts` using the mapping.
4. Keep filenames consistent with the target’s naming rules.

## Examples of canonical sources
- Agent index & usage: `.source/agents/instructions/list.md`
- Example agent format: `.source/agents/orchestrator.md`, `.source/agents/researcher.md`
- Example prompt format: `.source/prompts/General.prompt.md`

## Outputs & locations
- Generated outputs may be stored in workspace folders like `.factory/commands` when targeting Factory Droid (if requested).
- If the task requires **user-wide** locations (per target docs), do not write to workspace unless explicitly asked.

## Build/tests
- No build/test scripts or app runtime are defined in this repo; do not invent commands. Ask if validation is required.
