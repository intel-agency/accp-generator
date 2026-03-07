# Codex CLI Command Conversion Report

**Date:** February 7, 2026
**Target Client:** Codex CLI (`codex CLI`)
**Source Format:** GitHub Copilot prompt files (`.prompt.md`)
**Target Formats:** Codex custom prompts + Codex skills mirror

---

## Executive Summary

Converted **20** source prompt files from `.source/prompts` into:
- **20** custom prompt files in `C:\Users\nmill\.codex\prompts\`
- **20** skill files in `C:\Users\nmill\.codex\skills\<skill-name>\SKILL.md`

The conversion is lossless: each generated file contains a deterministic `codex_conversion_metadata` block preserving source frontmatter, parsed fields, unmapped fields, and parse warnings.

---

## Locations Used

- Source files: `.source/prompts/*.prompt.md`
- Target custom prompts (user-wide): `C:\Users\nmill\.codex\prompts\`
- Target skills (user-wide): `C:\Users\nmill\.codex\skills\`

---

## Field Mapping Summary

- `description` -> prompt frontmatter `description`; skill frontmatter `description`.
- `descrition` (typo) -> fallback for description mapping; original typo key preserved in metadata.
- `argument-hint` -> prompt frontmatter `argument-hint`; preserved in skill metadata block.
- `name` -> candidate source token for skill name generation.
- `model`, `tools`, `mode`, and unknown fields -> preserved in metadata block; optional skill fields are mapped only if schema compatibility is provable.
- Prompt output filenames keep the source basename (including `.prompt.md`).
- Skill names use slug + deterministic hash when invalid/collision/material normalization differences are detected.

---

## Generated Prompt Files

- `General.prompt.md` -> `C:\Users\nmill\.codex\prompts\General.prompt.md`
- `analyze-progress-doc.prompt.md` -> `C:\Users\nmill\.codex\prompts\analyze-progress-doc.prompt.md`
- `assign.prompt.md` -> `C:\Users\nmill\.codex\prompts\assign.prompt.md`
- `continue-orchestrating-project-setup.prompt.md` -> `C:\Users\nmill\.codex\prompts\continue-orchestrating-project-setup.prompt.md`
- `create-app-from-plans.prompt.md` -> `C:\Users\nmill\.codex\prompts\create-app-from-plans.prompt.md`
- `create-app-plan.prompt.md` -> `C:\Users\nmill\.codex\prompts\create-app-plan.prompt.md`
- `create-application.prompt.md` -> `C:\Users\nmill\.codex\prompts\create-application.prompt.md`
- `create-new-ai-app-spec.prompt.md` -> `C:\Users\nmill\.codex\prompts\create-new-ai-app-spec.prompt.md`
- `create-repo-custom-instructions.prompt.md` -> `C:\Users\nmill\.codex\prompts\create-repo-custom-instructions.prompt.md`
- `create-repo-summary.prompt.md` -> `C:\Users\nmill\.codex\prompts\create-repo-summary.prompt.md`
- `fix-failing-workflows.prompt.md` -> `C:\Users\nmill\.codex\prompts\fix-failing-workflows.prompt.md`
- `grind-pr-reviews.prompt.md` -> `C:\Users\nmill\.codex\prompts\grind-pr-reviews.prompt.md`
- `optimize-prompt.prompt.md` -> `C:\Users\nmill\.codex\prompts\optimize-prompt.prompt.md`
- `orchestrate-dynamic-workflow.prompt.md` -> `C:\Users\nmill\.codex\prompts\orchestrate-dynamic-workflow.prompt.md`
- `orchestrate-new-project.prompt.md` -> `C:\Users\nmill\.codex\prompts\orchestrate-new-project.prompt.md`
- `orchestrate-project-setup.prompt.md` -> `C:\Users\nmill\.codex\prompts\orchestrate-project-setup.prompt.md`
- `pr-review-comments(model, pr_num).prompt.md` -> `C:\Users\nmill\.codex\prompts\pr-review-comments(model, pr_num).prompt.md`
- `pr-review-comments.prompt.md` -> `C:\Users\nmill\.codex\prompts\pr-review-comments.prompt.md`
- `prompt-gemini-model.prompt.md` -> `C:\Users\nmill\.codex\prompts\prompt-gemini-model.prompt.md`
- `resolve-pr-comments.prompt.md` -> `C:\Users\nmill\.codex\prompts\resolve-pr-comments.prompt.md`

---

## Generated Skill Files

- `General.prompt.md` -> `general-prompt-6d31967c` -> `C:\Users\nmill\.codex\skills\general-prompt-6d31967c\SKILL.md`
- `analyze-progress-doc.prompt.md` -> `analyze-progress-doc-prompt-a87aa595` -> `C:\Users\nmill\.codex\skills\analyze-progress-doc-prompt-a87aa595\SKILL.md`
- `assign.prompt.md` -> `assign-prompt-cde78a7c` -> `C:\Users\nmill\.codex\skills\assign-prompt-cde78a7c\SKILL.md`
- `continue-orchestrating-project-setup.prompt.md` -> `continue-orchestrating-project-setup-prompt-5a34c944` -> `C:\Users\nmill\.codex\skills\continue-orchestrating-project-setup-prompt-5a34c944\SKILL.md`
- `create-app-from-plans.prompt.md` -> `create-app-from-plans-prompt-ae6903ec` -> `C:\Users\nmill\.codex\skills\create-app-from-plans-prompt-ae6903ec\SKILL.md`
- `create-app-plan.prompt.md` -> `create-app-plan-prompt-9a03a73c` -> `C:\Users\nmill\.codex\skills\create-app-plan-prompt-9a03a73c\SKILL.md`
- `create-application.prompt.md` -> `create-application-prompt-e18299ad` -> `C:\Users\nmill\.codex\skills\create-application-prompt-e18299ad\SKILL.md`
- `create-new-ai-app-spec.prompt.md` -> `create-new-ai-app-spec-prompt-ed2ab92e` -> `C:\Users\nmill\.codex\skills\create-new-ai-app-spec-prompt-ed2ab92e\SKILL.md`
- `create-repo-custom-instructions.prompt.md` -> `create-repo-custom-instructions-prompt-1a94ec2e` -> `C:\Users\nmill\.codex\skills\create-repo-custom-instructions-prompt-1a94ec2e\SKILL.md`
- `create-repo-summary.prompt.md` -> `create-repo-summary-prompt-a233c47d` -> `C:\Users\nmill\.codex\skills\create-repo-summary-prompt-a233c47d\SKILL.md`
- `fix-failing-workflows.prompt.md` -> `fix-failing-workflows` -> `C:\Users\nmill\.codex\skills\fix-failing-workflows\SKILL.md`
- `grind-pr-reviews.prompt.md` -> `grind-pr-reviews` -> `C:\Users\nmill\.codex\skills\grind-pr-reviews\SKILL.md`
- `optimize-prompt.prompt.md` -> `optimize-prompt-prompt-d5becba7` -> `C:\Users\nmill\.codex\skills\optimize-prompt-prompt-d5becba7\SKILL.md`
- `orchestrate-dynamic-workflow.prompt.md` -> `orchestrate-dynamic-workflow-prompt-c8e4309a` -> `C:\Users\nmill\.codex\skills\orchestrate-dynamic-workflow-prompt-c8e4309a\SKILL.md`
- `orchestrate-new-project.prompt.md` -> `orchestrate-new-project-prompt-6f46a669` -> `C:\Users\nmill\.codex\skills\orchestrate-new-project-prompt-6f46a669\SKILL.md`
- `orchestrate-project-setup.prompt.md` -> `orchestrate-project-setup-prompt-0bc3f8e6` -> `C:\Users\nmill\.codex\skills\orchestrate-project-setup-prompt-0bc3f8e6\SKILL.md`
- `pr-review-comments(model, pr_num).prompt.md` -> `pr-review-comments-model-pr-num-prompt-23244c58` -> `C:\Users\nmill\.codex\skills\pr-review-comments-model-pr-num-prompt-23244c58\SKILL.md`
- `pr-review-comments.prompt.md` -> `pr-review-comments-prompt-6b39760b` -> `C:\Users\nmill\.codex\skills\pr-review-comments-prompt-6b39760b\SKILL.md`
- `prompt-gemini-model.prompt.md` -> `prompt-gemini-model-prompt-e8d199d0` -> `C:\Users\nmill\.codex\skills\prompt-gemini-model-prompt-e8d199d0\SKILL.md`
- `resolve-pr-comments.prompt.md` -> `resolve-pr-comments-prompt-6520df2f` -> `C:\Users\nmill\.codex\skills\resolve-pr-comments-prompt-6520df2f\SKILL.md`

---

## Invalid/Irregular Source Files (Required List)

- `create-repo-custom-instructions.prompt.md`: malformed_yaml_key:descrition
- `optimize-prompt.prompt.md`: no_frontmatter
- `prompt-gemini-model.prompt.md`: multiple_frontmatter_like_blocks

All invalid/irregular files were converted using pass-through lossless handling; none were skipped.

---

## Validation Results

- Source count: `20`
- Generated prompt count: `20`
- Generated skill count: `20`
- Prompt files top-level `.md` count: `20`
- Skill directories with `SKILL.md`: `20`
- Skill name regex valid (`^[a-z0-9-]{1,64}$`): `True`
- Prompt metadata block present in all files: `True`
- Skill metadata block present in all files: `True`

---

## Issues Faced and Status

- Irregular source formats (`no_frontmatter`, multi-frontmatter-like blocks, typo key `descrition`) were encountered and handled without data loss. **Resolved.**
- Source `model/tools` fields are platform-specific and were preserved losslessly in metadata; optional skill mapping was withheld unless compatibility was provably safe. **Resolved conservatively.**
- Codex custom prompts are deprecated in favor of skills; both outputs were generated per requested scope. **Resolved by dual-output strategy.**

---

## Source References

- <https://developers.openai.com/codex/cli/custom-prompts>
- <https://developers.openai.com/codex/cli/getting-started>
- <https://developers.openai.com/codex/cli/overview>
- <https://developers.openai.com/codex/cli/skills>
