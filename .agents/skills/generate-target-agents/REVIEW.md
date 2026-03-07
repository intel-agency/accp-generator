# SKILL.md Hardening Review

## Issue 1: All Relative Paths Are Broken

The SKILL.md lives at `.agents/skills/generate-target-agents/SKILL.md` (3 levels deep from repo root). Every relative link is off by one directory level.

| Link in file | Resolves to | Should resolve to |
|---|---|---|
| `./../.source/agents/instructions/list.md` | `.agents/skills/.source/...` | `.source/agents/instructions/list.md` |
| `./../../generate-target-agents.md` | `.agents/generate-target-agents.md` | `generate-target-agents.md` (root) |
| `./../../docs/reports/` | `.agents/docs/reports/` | `docs/reports/` (root) |

**Solutions:**

| Option | Path Style | Pro | Con |
|---|---|---|---|
| **A) Fix relative to `../../../`** | `../../../.source/agents/...` | Standard markdown, works in any renderer | Fragile if skill folder moves; ugly triple-dot paths |
| **B) Use workspace-root-relative paths** | `/.source/agents/...` | Clean, easy to read, won't break if skill depth changes | Not valid markdown links in all renderers; GitHub won't resolve them |
| **C) Use relative but simplify with `./references/` indirection** | Keep a local `references/` dir with symlinks or notes | Progressive loading pattern; clean SKILL.md | Extra files to maintain; overkill for a few links |

**Recommended: A.** Standard relative paths with correct depth. They're ugly but correct and universally understood. The skill folder location is stable.

### REMARKS

<!-- Add your feedback here -->

---

## Issue 2: No Guidance on Re-Run Behavior

"When to Use" lists re-runs and repairs, but the procedure doesn't address what happens when target files already exist from a prior conversion.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Always overwrite (backup first)** | Backup existing, then overwrite unconditionally | Simple, predictable, backups protect against data loss | Loses manual customizations users may have made to target files |
| **B) Diff and prompt** | Compare generated output to existing file, show diff, ask user | Preserves manual edits; user stays in control | Breaks non-interactive goal; 25 agents × prompts = painful |
| **C) Overwrite with diff in report** | Overwrite unconditionally but include a diff summary in the conversion report | Simple execution; user can review changes after the fact | Still loses manual edits, but at least they're documented |

**Recommended: C.** Overwrite unconditionally (backup-first is already in the procedure), and document what changed in the report. This maintains the non-interactive goal while giving visibility.

### REMARKS

<!-- Add your feedback here -->

---

## Issue 3: "Parses Correctly" Is Undefined (Step 5.3)

The verify-after-swap step says "confirm it parses correctly" but gives no criteria for what that means — especially since targets have different formats (YAML frontmatter, JSON, YAML config files).

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Target-specific validation rules** | Add a substep: "validate per target format rules discovered in step 3" | Accurate; catches real errors | Requires the LLM to figure out validation per target, adding complexity |
| **B) Generic frontmatter + non-empty body check** | Validate YAML parses, required fields present, body non-empty | Simple, covers 90% of cases | May miss target-specific issues (e.g., Kilo Code slug regex) |
| **C) Enumerate explicit checks** | List: YAML parses, required fields present, field values match naming rules, body non-empty, file extension correct | Thorough, actionable | Slightly verbose; some checks are target-dependent |

**Recommended: C.** Enumerate the checks explicitly. The LLM needs concrete validation criteria, not vague instructions. Target-specific rules (like slug regex) are already captured in the learned index from step 3, so referencing those is natural.

### REMARKS

<!-- Add your feedback here -->

---

## Issue 4: "Lossless" Is Ambiguous for Structural Transformations

Some targets don't have a "body" at all. Kilo Code puts the system prompt into a `roleDefinition` YAML field. "Preserve verbatim" doesn't apply — the content is preserved but the structure changes fundamentally. The skill should clarify what "lossless" means.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Define lossless as "information-preserving"** | Clarify: all source *information* must appear in the target, even if the structural representation changes | Accurate; handles structural mismatches | Requires the LLM to use judgment on what constitutes "same information" |
| **B) Define lossless as "round-trippable"** | The target must contain enough information to reconstruct the source | Very strict; guarantees no data loss | Impractical — some targets can't represent all source fields |
| **C) Define lossless with explicit categories** | "Required: name, description, body content must appear. Best-effort: tool mappings, model mappings. Document-only: unmappable fields preserved as comments" | Clear priority tiers; actionable | More text in the skill |

**Recommended: C.** Explicit tiers give the LLM clear guidance on priorities without making impossible demands. Some fields genuinely can't be mapped 1:1.

### REMARKS

<!-- Add your feedback here -->

---

## Issue 5: Primary Report File Not Named

Step 6 says create a directory at `docs/reports/<target>/` but doesn't specify the primary report filename. This could lead to inconsistent naming across runs.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Fixed name: `conversion-report.md`** | Always `docs/reports/<target>/conversion-report.md` | Predictable; easy to find | Can't distinguish between re-run reports |
| **B) Timestamped: `conversion-report-YYYYMMDD.md`** | Append date to filename | Each run is preserved; history visible | Clutter over many runs |
| **C) Fixed primary + timestamped archive** | Primary is always `conversion-report.md`; previous versions archived as `conversion-report.bak.YYYYMMDD.md` | Clean primary location; history preserved | Slightly more complex |

**Recommended: A.** Simple fixed name. The backup procedure already handles file protection. If re-run history matters, git history covers it — these files are in the repo.

### REMARKS

<!-- Add your feedback here -->

---

## Issue 6: No Error / Fallback Guidance

What if web fetch fails (rate limited, docs moved, site down)? What if a source file has malformed frontmatter? The procedure has no error handling.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Fail fast with clear message** | If web fetch fails or source is malformed, stop and report the error | Simple; no silent corruption | One bad file blocks entire batch |
| **B) Skip and continue** | Log the failure, skip that file/step, continue with the rest | Maximizes output; partial results are useful | Could produce incomplete conversion that looks complete |
| **C) Fail fast per-file, continue batch** | Malformed source → skip that file with error in report. Web fetch failure → stop entirely (can't proceed without target format) | Good balance; web fetch is a hard dependency, individual files aren't | Slightly more nuanced logic |

**Recommended: C.** Web fetch failure is a hard blocker (can't generate without knowing the target format). Individual malformed source files should be skipped with errors logged in the report, so the rest of the batch succeeds.

### REMARKS

<!-- Add your feedback here -->

---

## Issue 7: Source Path Is Hardcoded

`.source/agents/` is baked into the procedure. If the repo restructures, the skill silently breaks.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Keep hardcoded, document the assumption** | Add a note: "Source location is `.source/agents/` per repo convention" | Simple; self-documenting | Still breaks on restructure |
| **B) Read from a config or the task guide** | Reference `generate-target-agents.md` for the source location | Single source of truth | Adds an indirection step |
| **C) Accept as argument with default** | Source path could be overridable via prompt but defaults to `.source/agents/` | Flexible | `argument-hint` already used for target; overloading is confusing |

**Recommended: A.** This is a workspace-scoped skill tied to this specific repo's structure. Hardcoding is fine — just document the assumption so it's easy to find and update if needed.

### REMARKS

<!-- Add your feedback here -->

---

## Issue 8: Quality Checks Are Disconnected from Procedure

The quality checklist is at the bottom but not woven into the procedure steps. The LLM might skip them or treat them as optional.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Inline checks into each step** | Add verification substep at end of each procedure step | Checks happen at point of action; hard to skip | Makes procedure steps longer |
| **B) Keep as final gate** | Explicit "Step 7: Run Quality Checks" | Clear separation; easy to audit | LLM may have to redo work if checks fail late |
| **C) Both: inline + final gate** | Light inline checks per step, full checklist as final validation | Defense in depth | More text/repetition |

**Recommended: B.** Promote the existing checklist to a numbered "Step 7" so it's part of the sequential procedure, not an appendix. This ensures the LLM treats it as a required step.

### REMARKS

<!-- Add your feedback here -->

---

## Summary Table

| # | Issue | Severity | Recommended Fix |
|---|---|---|---|
| 1 | Broken relative paths | **High** | Fix to `../../../` depth |
| 2 | No re-run behavior defined | **Medium** | Overwrite + diff in report |
| 3 | "Parses correctly" undefined | **Medium** | Enumerate explicit checks |
| 4 | "Lossless" ambiguous | **Medium** | Define priority tiers |
| 5 | Report filename unspecified | **Low** | Fixed name `conversion-report.md` |
| 6 | No error/fallback guidance | **Medium** | Fail-fast for fetch, skip-and-log for files |
| 7 | Hardcoded source path | **Low** | Document the assumption |
| 8 | Quality checks disconnected | **Medium** | Promote to Step 7 |
