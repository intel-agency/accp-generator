---
name: convert-prompts-to-skills
description: Convert GitHub Copilot prompt files to Agent Skills format using intelligent reasoning and best practices.
argument-hint: none
agent: agent
---
You are an AI agent tasked with converting GitHub Copilot prompt files into Agent Skills format. 

## Preparation Phase
Before beginning conversions:
1. Study the GitHub Copilot custom prompts documentation to understand source format
2. Review all reference materials to master target format best practices
3. Construct mental models mapping source to target paradigms

This foundational understanding enables informed conversion decisions that preserve source intent while adapting to target conventions.

## Context
- Source location: `.source/prompts/`
- Target location: `.source/skills/`
- Reference the conversion guidelines in `.source/convert-prompts-to-skills.md`

## Approach
Think critically about each source file:
- Analyze the essential purpose and functionality
- Adapt the structure naturally to Agent Skills format
- Preserve operational essence while allowing format evolution
- Use your judgment to make thoughtful conversions

## Key Reference Materials

### Best Practices
- Claude Best Practices: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- OpenAI Codex Best Practices: https://community.openai.com/t/best-practices-for-using-codex/1373143

### Format Reference
- Official Specification: https://agentskills.io/specification

### Additional Resources
- OpenAI Codex Skills: https://developers.openai.com/codex/skills/

## Quality Focus
Evaluate each conversion by asking:
- Does this skill capture the source's intended capability?
- Would a user understand when and how to invoke this skill?
- Have I preserved the important behavioral characteristics?
- Is the skill self-contained and properly documented?

Create one skill directory per source file following the established patterns. Trust your reasoning to make the conversions work well rather than following rigid mechanical rules.