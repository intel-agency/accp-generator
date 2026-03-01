# Convert Prompts to Skills - AGENT GUIDELINES

## CONTEXT
You are an AI agent tasked with converting GitHub Copilot prompt files into Agent Skills format. Approach this conversion thoughtfully, preserving the essence and functionality of each source file while adapting to the target format's conventions.

Before beginning conversions, develop a deep understanding of both source and target formats:

1. **Study the Source**: Read the GitHub Copilot custom prompts documentation to fully understand the source format structure and capabilities
2. **Master the Target**: Review all three reference URLs to understand Agent Skills best practices and specifications
3. **Build Mental Models**: Construct a mapping between source and target paradigms to guide your conversion decisions

This foundational understanding will enable you to make informed judgments about how to best translate each source file's intent into the target format.

## SOURCE_UNDERSTANDING
- Location: `.source/prompts/`
- File types: Various extensions (.prompt.md, .agent.md, .chatmode.md, .instructions.md)
- Structure: YAML frontmatter containing metadata + Markdown body with instructions
- Key fields typically present: description, mode, tools, model
- **Source Format Documentation**: https://code.visualstudio.com/docs/copilot/customization/prompt-files

## TARGET_FORMAT
- Location: `.source/skills/`
- Structure: Each skill in its own directory named `{skill-name}/SKILL.md`
- Format: YAML frontmatter with required `name` and `description` fields + Markdown body
- Reference: https://agentskills.io/specification

## REFERENCE_MATERIALS

**Reading Sequence**: 
1. First, study the GitHub Copilot source format documentation
2. Then review all target format references below to build comprehensive understanding
3. Finally, construct mental mappings between source and target paradigms

### Source Format Foundation
- GitHub Copilot Custom Prompts: https://code.visualstudio.com/docs/copilot/customization/prompt-files

### Best Practices Documentation
- Claude Best Practices: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- OpenAI Codex Best Practices: https://community.openai.com/t/best-practices-for-using-codex/1373143

### Format Specification
- Official Agent Skills Specification: https://agentskills.io/specification

### Additional References
- OpenAI Codex Skills Functionality: https://developers.openai.com/codex/skills/

## CONVERSION_PRINCIPLES

### Core Philosophy
Think critically about each source file:
- What is the essential purpose of this prompt/agent?
- How should that purpose translate to a skill context?
- What information is crucial to preserve vs. what can be adapted?

### Field Translation Guidance
- **description**: This is the heart of the skill - capture the core function and use case
- **tools**: Convert from array format to space-delimited string for allowed-tools
- **mode/model**: Preserve contextually in metadata rather than forcing direct mapping
- **name**: Derive from filename but optimize for clarity and searchability

### Preservation Strategy
For any source information that doesn't have a direct target equivalent:
- Store in the `metadata` section with descriptive keys
- Add explanatory comments when helpful
- Maintain the original intent even if the structure changes

## FLEXIBLE_APPROACH

### Reasoning Process
1. **Analyze** each source file holistically - don't just map fields mechanically
2. **Understand** the intended functionality and user interaction pattern
3. **Adapt** the structure to fit naturally within the Agent Skills paradigm
4. **Preserve** the operational essence while allowing format evolution

### Decision Making
When encountering ambiguous situations:
- Consider multiple interpretation approaches
- Choose the one that best maintains the original's effectiveness
- Document your reasoning in metadata when the choice isn't obvious
- Prioritize usability over strict format adherence

### Quality Judgment
Evaluate each conversion by asking:
- Does this skill capture the source's intended capability?
- Would a user understand when and how to invoke this skill?
- Have I preserved the important behavioral characteristics?
- Is the skill self-contained and properly documented?

## VALIDATION_GUIDELINES

### Essential Checks
- Directory name matches the skill's internal name field
- Required fields (name, description) are present and valid
- YAML syntax is correct
- Skill loads without errors in validation tools

### Quality Indicators
- Description clearly explains what the skill does and when to use it
- Body content provides actionable guidance
- Metadata preserves relevant source context
- Overall structure feels natural for an Agent Skill

## OUTPUT_EXPECTATIONS

Create one skill directory per source file in `.source/skills/` following the established patterns. Each conversion should represent your thoughtful interpretation of how to best express that capability within the Agent Skills framework.

Trust your judgment to make the conversions work well rather than following rigid mechanical rules.

<!-- ## Learned target type index

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
- Notes: custom prompts are deprecated in favor of skills, but still supported. For lossless conversion, preserve source-only fields (`mode`, source-specific `tools`, unknown keys) in a metadata comment block in generated files. -->
