# generate-target-model-providers SKILL.md Hardening Review

## General Fixes Applied (from agents skill review)

All 8 general improvements from the agents skill review have been pre-applied:

| # | Fix | Status |
|---|---|---|
| 1 | Correct relative paths (`../../../`) | Applied |
| 2 | Re-run behavior (merge + diff in report) | Applied |
| 3 | Explicit verification checks | Applied |
| 4 | Lossless priority tiers (Required/Best-effort/Document-only) | Applied |
| 5 | Fixed report filename (`conversion-report.md`) | Applied |
| 6 | Error/fallback guidance (fail-fast for fetch, skip for malformed files) | Applied |
| 7 | Documented hardcoded source path | Applied |
| 8 | Quality checks promoted to Step 7 | Applied |

---

## Model-Providers-Specific Issues

### Issue P1: Provider-Centric → Model-Centric Flattening Creates Naming Collisions

The source is provider-centric (provider → endpoints → models). Most targets are model-centric (flat list). When multiple providers expose the same model ID (e.g., two providers both offering `claude-sonnet-4-20250514`), the flattened entries will collide. The skill mentions merge conflict detection for re-runs but doesn't address collisions **within a single run** across different source providers.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Namespace model IDs with provider** | Use composite IDs: `<provider-id>/<model-id>` | Guarantees uniqueness | Some targets may not accept `/` in model IDs |
| **B) Use display name for deduplication** | Composite display name `"<display_name> [<provider.name>]"` already differentiates; use provider ID as suffix on the model entry key | Human-readable; leverages existing composite name | Model ID sent to API must still be the original |
| **C) Detect and rename on collision** | During generation, track seen model IDs; on collision, append provider ID suffix to the entry key (not the API model ID) | Correct API calls; unique config keys | Requires collision detection logic |

**Recommended: C.** The API model ID must stay unchanged (it's what the provider expects), but the config entry key can be made unique. This mirrors the existing merge conflict strategy (rename new entry, not the model ID field).

### REMARKS

<!-- Add your feedback here -->

---

### Issue P2: API Key Security — Insufficient Guidance on When Inline Values Are Acceptable

The skill says "inline value — only if target config is at a user-wide location (not version-controlled)" but doesn't address cases where the user-wide config might still be synced (e.g., VS Code settings sync, dotfiles repos). The model-providers task guide has a 4-point key handling strategy but the skill's version is condensed.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Always prefer env var references** | Default to env var syntax in all cases; only use inline as last resort with explicit warning | Safest; no accidental exposure | Some targets' env var syntax may be clunky |
| **B) Add sync risk warning** | Keep current logic but add: "If the user-wide config is synced via settings sync or dotfiles, treat it as version-controlled" | Covers the edge case | Relies on LLM detecting sync configuration |
| **C) Tiered preference: env var → credential store → inline + warning** | Explicit priority order matching the source task guide's 4-point strategy | Complete; matches source behavior | More verbose |

**Recommended: C.** Restore the full 4-point priority from the task guide. API keys are high-stakes; this is not a place to condense.

### REMARKS

<!-- Add your feedback here -->

---

### Issue P3: `image_support` Boolean Inversion Is Error-Prone

The source uses `image_support: true/false`. Some targets use `noImageSupport: true/false` (inverted). Others use `capabilities.images: true/false` (not inverted). The skill mentions inversion but doesn't provide a clear decision rule for when to invert vs not.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Add explicit inversion table** | Document: `noImageSupport` → invert; `capabilities.images` → direct; other → document in report | Clear, actionable | Goes stale if targets add new field names |
| **B) Defer to discovered target docs** | Step 3 discovery should capture the exact field name and polarity | Always current | LLM might not think to check polarity during discovery |
| **C) Add "field polarity" to discovery checklist** | Add: "For boolean capability fields, note whether true means 'supports' or 'does not support'" | Ensures discovery captures polarity; step 4 uses it | Slight addition to step 3 |

**Recommended: C.** Add polarity to the step 3 discovery checklist. This is a generalizable improvement — any boolean field could be inverted, not just image support.

### REMARKS

<!-- Add your feedback here -->

---

### Issue P4: Composite Display Name Convention Not Flexible Enough

The skill says `"<display_name> [<provider.name>]"` unless the target has its own convention. Some targets may truncate long display names, or the composite format may not match the target's UI style.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Keep as default, let target override** | Current behavior is fine as a default | Simple; works for known targets | May produce awkward names for targets with short display fields |
| **B) Add max-length guidance** | "If target has a max display name length, truncate provider name" | Prevents truncation issues | More complex |
| **C) Make composition configurable in discovery** | Step 3 captures display name convention and max length; step 4 adapts | Always correct for the target | More to capture in step 3 |

**Recommended: A.** The current default is good. Targets with specific conventions will be discovered in step 3, and the "unless the target has its own convention" clause already handles it.

### REMARKS

<!-- Add your feedback here -->

---

### Issue P5: No Guidance on Empty/Stub Provider Handling Beyond Skip

The skill says "skip provider files whose `models` lists are empty." But it doesn't say whether to log skipped stubs or include them in the report. For consistency with the per-file skip logic (which logs errors), stubs should also be logged.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Log skipped stubs in report** | Add a "Skipped providers" section listing stubs with reason "empty models list" | Consistent with error skip logging; full visibility | Slightly more verbose report |
| **B) Skip silently** | Don't mention stubs; they're intentionally empty | Cleaner report | User may wonder why a provider is missing |

**Recommended: A.** Log them. Consistency with the error-skip pattern and full visibility outweigh the minor verbosity.

### REMARKS

<!-- Add your feedback here -->

---

### Issue P6: No Validation of Resolved API Keys

Step 5.6 verifies config structure and field presence, but doesn't verify that resolved API keys are actually non-empty. If `.api_keys` has a line like `KIMI_CODING_API_KEY=` (empty value), the generated config will silently have an empty API key.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Warn on empty API key** | If resolved value is empty or whitespace, log a WARNING and include it in the report | Doesn't block the run; surfaces the issue | User may not notice the warning |
| **B) Fail the entry** | Skip the provider entry if the API key resolves to empty | Prevents broken configs | One missing key blocks an entire provider (all its models) |
| **C) Warn + generate with placeholder** | Insert a placeholder like `<SET_YOUR_API_KEY>` and warn in report | Config is valid but non-functional; user action required is obvious | Placeholder may confuse automated systems |

**Recommended: A.** Warn but don't block. The user may have intentionally left a key blank for a provider they haven't set up yet. The report makes it visible.

### REMARKS

<!-- Add your feedback here -->

---

## Summary Table

| # | Issue | Severity | Recommended Fix |
|---|---|---|---|
| P1 | Naming collisions in flattened output | **High** | Detect + rename entry key on collision |
| P2 | API key security guidance too condensed | **High** | Restore full 4-point priority from task guide |
| P3 | Boolean `image_support` inversion error-prone | **Medium** | Add field polarity to step 3 discovery |
| P4 | Composite display name not flexible enough | **Low** | Keep current default (already handled) |
| P5 | Stub providers not logged in report | **Low** | Log skipped stubs in report |
| P6 | No validation of empty API keys | **Medium** | Warn on empty, don't block |
