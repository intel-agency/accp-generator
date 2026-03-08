# generate-target-commands SKILL.md Hardening Review

## General Fixes Applied (from agents skill review)

All 8 general improvements from the agents skill review have been pre-applied:

| # | Fix | Status |
|---|---|---|
| 1 | Correct relative paths (`../../../`) | Applied |
| 2 | Re-run behavior (overwrite + diff in report) | Applied |
| 3 | Explicit verification checks | Applied |
| 4 | Lossless priority tiers (Required/Best-effort/Document-only) | Applied |
| 5 | Fixed report filename (`conversion-report.md`) | Applied |
| 6 | Error/fallback guidance (fail-fast for fetch, skip-and-log for files) | Applied |
| 7 | Documented hardcoded source path | Applied |
| 8 | Quality checks promoted to Step 7 | Applied |

---

## Commands-Specific Issues

### Issue C1: Commands vs Skills Ambiguity

Some targets (Claude Code, Codex CLI) have **both** a legacy commands format and a newer skills format, with the docs recommending skills. The skill instructs discovery of "custom commands, slash commands, or skills" but doesn't provide clear guidance on which to prefer when both exist.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Always prefer skills** | If the target offers both commands and skills, generate skills | Future-proof; aligns with vendor recommendations | May miss features only available in legacy commands |
| **B) Always prefer commands** | Generate the simpler command format | Simpler translation; fewer structural changes | Deprecated in some targets |
| **C) Prefer skills, document the alternative** | Default to skills; note in the report that a legacy command alternative exists | Best of both worlds; user can opt-in to legacy | Slightly more complex report |

**Recommended: C.** Default to the newer format but document the alternative so users can choose.

### REMARKS

<!-- Add your feedback here -->
Ask use which combinatin of target types they want: commands, skills, or both. Then generate accordingly. This gives the user the most agency and avoids making assumptions about their preferences. The report can note which files were generated in which format for clarity. If user doesn't know or care, default to commands. For reruns, inform the user which types exist at target already, e.g. "This target has existing skills but no commands. Do you want to generate skills, commands, or both?" This way the user can make an informed choice based on the current state of their target.
---

### Issue C2: Source Format Differs from Agents

The agents skill converts from Claude Code format. The commands skill converts from **VS Code Copilot prompt format** — a different source. The skill mentions `*.prompt.md` but doesn't explicitly enumerate the source frontmatter fields the way the agents skill does for Claude Code fields. This could lead the LLM to miss source fields during mapping.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Enumerate known source fields inline** | List: `name`, `description`, `argument-hint`, `mode`, `tools`, `model`, `user-invocable`, `disable-model-invocation`, etc. | Complete; LLM can't miss a field | Longer step 2; may go stale if Copilot adds new fields |
| **B) Reference the official docs** | Add a link to the Copilot prompt file structure docs | Always up-to-date | LLM has to fetch and parse extra docs |
| **C) Enumerate + reference** | List the known fields AND link to official docs for completeness | Best coverage | Slightly verbose |

**Recommended: C.** Enumerate current fields for immediate actionability, plus a reference link for any future additions.

### REMARKS

<!-- Add your feedback here -->

---

### Issue C3: No Directory-Based Skill Structure Guidance

When the target uses directory-based skills (e.g., Claude Code `SKILL.md` inside a named directory), the source is a flat `.prompt.md` file. The skill mentions this in the verification step but doesn't provide guidance on **how** to structure the directory — what goes in `SKILL.md` vs whether to create `references/` or `scripts/` subdirs.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Minimal: one SKILL.md per directory** | Just create `<skill-name>/SKILL.md` with all content | Simple; sufficient for most prompt-to-skill conversions | Doesn't leverage progressive loading |
| **B) Split large prompts** | If the source prompt body exceeds 500 lines, split into `SKILL.md` + `references/` files | Follows skill best practices for progressive loading | Adds complexity; most prompts won't trigger this |
| **C) Minimal by default, split guidance in report** | Default to single `SKILL.md`; note in report if a prompt was large enough to warrant splitting | Keeps automation simple; gives actionable follow-up advice | Defers the work to the user |

**Recommended: A.** Most prompt files are small enough for a single `SKILL.md`. Splitting is an optimization the user can request separately.

### REMARKS

<!-- Add your feedback here -->

---

### Issue C4: Variable Syntax Adaptation Not Detailed Enough

Step 4 mentions `$ARGUMENTS` → target equivalent, but different targets handle variable interpolation very differently. OpenCode has `$1`–`$N` positional args, `@file` includes, and `!command` injection. Factory uses `$ARGUMENTS`. Claude Code skills don't have built-in variable interpolation at all.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Add a variable syntax mapping table** | Include a reference table of known variable syntaxes per target | Actionable; LLM can apply directly | Goes stale as targets evolve; duplicates learned index info |
| **B) Defer to discovered target docs** | Step 3 discovery should capture variable syntax conventions; step 4 uses them | Always current; no duplication | LLM might not think to look for variable syntax during discovery |
| **C) Add "variable syntax" to the discovery checklist** | Add variable syntax as an explicit extraction point in step 3, then reference it in step 4 | Ensures discovery captures it; step 4 uses current info | Slight addition to step 3 |

**Recommended: C.** Add variable syntax to the step 3 extraction list so it's always captured, then step 4 naturally uses it.

### REMARKS

<!-- Add your feedback here -->

---

## Summary Table

| # | Issue | Severity | Recommended Fix |
|---|---|---|---|
| C1 | Commands vs Skills ambiguity | **Medium** | Prefer skills, document alternatives |
| C2 | Source fields not enumerated | **Medium** | Enumerate + reference official docs |
| C3 | No directory-based skill structure guidance | **Low** | Minimal single SKILL.md default |
| C4 | Variable syntax adaptation insufficient | **Medium** | Add to step 3 discovery checklist |
