# generate-target-mcp-servers SKILL.md Hardening Review

## General Fixes Applied (from agents skill review)

All 8 general improvements from the agents skill review have been pre-applied:

| # | Fix | Status |
|---|---|---|
| 1 | Correct relative paths (`../../../`) | Applied |
| 2 | Re-run behavior (merge + diff in report) | Applied |
| 3 | Explicit verification checks | Applied |
| 4 | Lossless priority tiers (Required/Best-effort/Document-only) | Applied |
| 5 | Fixed report filename (`conversion-report.md`) | Applied |
| 6 | Error/fallback guidance (fail-fast for fetch and source parse) | Applied |
| 7 | Documented hardcoded source path | Applied |
| 8 | Quality checks promoted to Step 7 | Applied |

---

## MCP-Servers-Specific Issues

### Issue M1: Single Source File vs Per-File Skip Logic

The agents and commands skills iterate over many source files and skip individual malformed ones. MCP servers have a **single** source file (`mcp.json`) containing multiple server entries. The skill correctly says "stop the run" if the file is unparseable, but doesn't address what happens if **individual server entries** within the file are malformed (e.g., a stdio server missing `command`).

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Skip malformed entries** | If an individual server entry is missing required fields, skip it and log the error | Maximizes output; consistent with agents/commands behavior | Partial conversion could look complete |
| **B) Fail the entire run** | Any malformed entry stops the run | Strict data integrity | One bad entry blocks all servers |
| **C) Skip entry, add warning to report** | Skip the entry, log it prominently in the report with a WARNING flag | Good balance; explicit visibility into what was skipped | Slightly more verbose report |

**Recommended: C.** Skip individual malformed entries with prominent warnings. This is consistent with the per-file skip logic in agents/commands but adapted for the single-file-multiple-entries pattern.

### REMARKS

<!-- Add your feedback here -->

---

### Issue M2: Merge Conflict Strategy Could Lose Disabled State

The merge logic says: same name + same fields → skip; same name + different fields → preserve existing + rename new. But if the user previously disabled a server in the target config, and the source has it enabled (or vice versa), the "different fields" path will create a duplicate instead of updating the disabled state.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Treat disabled as a non-differentiating field** | When comparing "same fields", ignore the `disabled` flag — update it in place | Respects source as truth for enable/disable state | Overwrites user's manual disable choices |
| **B) Keep current behavior** | Disabled state differences create a renamed entry | Never loses user's manual changes | Accumulates duplicate entries with different disable states |
| **C) Source disabled state wins, but log the override** | Update disabled state in place; log in report when a user's disable was overridden | Clean config; full transparency | Source becomes the authority for disabled state |

**Recommended: A.** The source is the source of truth. If the user manually disabled a server, that's a local override — the source represents the canonical state. Skip the entry if all substantive fields match (ignoring `disabled`), but update its disabled state to match source.

### REMARKS

<!-- Add your feedback here -->

---

### Issue M3: Transport Type Mapping May Require Version-Dependent Logic

The source has `stdio` and `http`. Some targets distinguish between `sse` and `streamable-http` for HTTP-based transports — the distinction depends on the MCP protocol version the server supports. The skill says to map `http` to the target's equivalent but doesn't guide how to determine whether `sse` or `streamable-http` is correct.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Default to `sse`, document alternative** | Map `http` → `sse` (most widely supported); note in report that `streamable-http` may be needed for newer servers | Safe default; most MCP servers still use SSE | May require user intervention for newer servers |
| **B) Try `streamable-http` first** | Use newer protocol by default | Forward-looking | May break with older MCP servers |
| **C) Defer to target docs** | Step 3 discovery should determine which HTTP transport the target supports and prefers | Always correct for the target | Doesn't solve which is correct for the *server* (source-side) |
| **D) Add to discovery + default to most compatible** | Step 3 captures supported transports; default to the most widely compatible one; note alternatives in report | Best balance of correctness and safety | Slightly more complex step 3 |

**Recommended: D.** Capture the target's supported transports in step 3, use the most broadly compatible one as the default, and document alternatives in the report.

### REMARKS

<!-- Add your feedback here -->

---

### Issue M4: Secrets Handling Inconsistency with Model Providers Skill

The model providers skill has detailed guidance on API key resolution (env var syntax, credential stores, inline values). The MCP servers skill has basic guidance ("resolve from `.api_keys`") but doesn't enumerate the same resolution strategies. Since MCP servers can also require API keys via `env` fields, the guidance should be equally detailed.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Add same API key resolution detail** | Mirror the model-providers skill's 4-point key resolution strategy | Consistent across skills; thorough | Some duplication across skills |
| **B) Reference the model-providers skill** | Say "follow the same API key resolution strategy as generate-target-model-providers" | DRY; no duplication | Cross-skill dependency; fails if the other skill isn't available |
| **C) Add concise inline guidance** | Add a shorter version of the key resolution rules specific to MCP env vars | Self-contained; appropriately scoped | May drift from model-providers skill over time |

**Recommended: C.** Add concise, self-contained guidance. The MCP env var use case is simpler (usually just env var passthrough, not inline values) so it doesn't need the full model-providers treatment.

### REMARKS

<!-- Add your feedback here -->

---

### Issue M5: No Guidance on Package Version Pinning

The source has `version` fields for some servers (e.g., `@modelcontextprotocol/server-sequential-thinking@0.0.1`). When translating commands/args that include `npx <package>@latest`, the skill should address whether to use the pinned version from the source or `@latest`.

**Solutions:**

| Option | Approach | Pro | Con |
|---|---|---|---|
| **A) Always use pinned version from source** | Replace `@latest` with `@<version>` from source | Reproducible; matches source intent | May lag behind if source version isn't updated |
| **B) Always use `@latest`** | Ignore source `version` field | Always current | Non-reproducible; may break on incompatible updates |
| **C) Use pinned if present, `@latest` if not** | Respect the source's version field; if absent, use `@latest` | Gives source authors control; sensible default | Requires version field inspection per entry |

**Recommended: C.** Respect the source's pinned version when present (it was pinned deliberately), fall back to `@latest` when no version is specified. Document the version used in the report.

### REMARKS

<!-- Add your feedback here -->

---

## Summary Table

| # | Issue | Severity | Recommended Fix |
|---|---|---|---|
| M1 | Single-file per-entry skip logic | **Medium** | Skip entry + WARNING in report |
| M2 | Merge conflict loses disabled state | **Medium** | Ignore disabled in comparison; update in place |
| M3 | Transport type version-dependent | **Medium** | Discover + default to most compatible |
| M4 | Secrets handling less detailed than model-providers | **Low** | Add concise inline guidance |
| M5 | No version pinning guidance | **Low** | Pinned if present, @latest if not |
