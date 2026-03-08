---
name: generate-target-mcp-servers
description: "Translate source VS Code MCP server configurations into a target client's MCP config format. Use when: converting MCP server configs to Claude Code, Factory Droid, OpenCode, Kilo Code, or other targets; migrating MCP server setups cross-platform; building field mappings from source to target format."
argument-hint: "Target client name or docs URL (e.g., 'Claude Code', 'Factory Droid', 'OpenCode')"
tools:
  - read
  - edit
  - search
  - command
  - fetch
---

# Generate Target Client MCP Servers

Translate source MCP server configurations (VS Code Insiders `mcp.json` format) into a target client's MCP configuration format, then place them at the target's user-wide config location.

## When to Use

- Converting `.source/mcp-servers/Code - Insiders/mcp.json` server entries to a new target client format
- Re-running a conversion after source MCP configs have been updated
- Adding support for a new target client type
- Verifying or repairing a previous conversion

## Procedure

### 1. Detect Environment

Detect whether the source is being run from **Windows** or **Linux/WSL**. Record this as the target environment — target files will be placed at the target's user-wide location for this same environment.

### 2. Identify Source Files

Read the MCP server configuration from `.source/mcp-servers/Code - Insiders/` (hardcoded per repo convention — update here if the repo restructures).

The source is a VS Code Insiders `mcp.json` file with a `servers` object. Each server entry has:

- `type` — Transport type (`stdio` or `http`)
- `command`, `args` — For `stdio` servers
- `url` — For `http` servers
- `version`, `gallery` — Metadata fields
- `disabled` — Whether the server is disabled
- `env` — Environment variables (if present)

If the source file cannot be parsed, **stop the run** — unlike agent/command files where individual items can be skipped, MCP configs are typically a single file.

If the source file parses successfully but **individual server entries** are malformed (e.g., a `stdio` server missing `command`, or an `http` server missing `url`), **skip that entry** and log a prominent WARNING in the conversion report with the server name and the missing/invalid fields. Continue processing the remaining entries. This keeps the per-entry skip behavior consistent with the agents and commands skills while adapting to the single-file-multiple-entries pattern.

If an `.api_keys` file exists at `.source/mcp-servers/Code - Insiders/.api_keys`, load the `NAME=VALUE` pairs for secret resolution.

Reference: [Source MCP servers directory](../../../.source/mcp-servers/)

### 3. Discover Target Format

Given the target client name or docs URL:

1. **Check the learned target index first.** Look in [generate-target-mcp-servers.md](../../../generate-target-mcp-servers.md) under "Learned target type index" for a cached entry matching the target. If found, use that cached information and skip to step 4.
2. **If no cached entry exists, discover via web fetch.** Use web fetch tools to locate the target's documentation site **non-interactively** (do not ask the user for URLs). Search for and recursively follow documentation links to find the section on MCP server configuration, MCP integration, or tool server setup. Extract:
   - User-wide MCP config location (for both Windows and Linux/WSL when documented)
   - File format (JSON, YAML, TOML, etc.) and the specific key/section for MCP servers
   - Valid fields for each MCP server entry
   - Transport types supported (`stdio`, `http`, `sse`, `streamable-http`, etc.) — note which HTTP-based transport the target prefers or defaults to, so generation can select the most broadly compatible one
   - Environment variable / secrets mechanism for MCP servers
3. **Cache the discovery.** Record the newly discovered target type as a new subsection in the "Learned target type index" of [generate-target-mcp-servers.md](../../../generate-target-mcp-servers.md), including the documentation URL, environment, and all extracted details. This prevents re-fetching on future runs.

**If web fetch fails** (rate limited, docs moved, site down), **stop the entire run** — the target format is a hard dependency. Report the failure clearly with the URL attempted and the error received.

### 4. Build Field Mapping

Create a mapping between each source field and the most appropriate target field:

| Source (VS Code mcp.json) | Target | Transformation |
|---------------------------|--------|----------------|
| Server name (key) | *(target's server name/id)* | *(document rule)* |
| `type` | *(target's transport type)* | *(map: stdio→stdio; http→target's preferred HTTP transport from step 3 discovery, defaulting to the most broadly compatible option; document alternatives in report)* |
| `command` | *(target's command field)* | *(document rule)* |
| `args` | *(target's args field)* | *(document rule)* |
| `url` | *(target's URL/endpoint field)* | *(document rule)* |
| `env` | *(target's env var mechanism)* | *(resolve secrets from .api_keys)* |
| `disabled` | *(target's disabled mechanism)* | *(flag, comment, or omission — document choice)* |
| `version` | *(comment/metadata)* | *(preserve if possible)* |
| `gallery` | *(comment/metadata)* | *(preserve if possible)* |

**CRITICAL: Lossless translation.** All source information must appear in the target output. Use these priority tiers:

- **Required (must appear):** Server name, transport type, command/args (stdio) or URL (http).
- **Best-effort (map if target supports):** `env`, `disabled` state, transport type mapping.
- **Document-only (preserve as comments or in report):** `version`, `gallery`, and any fields the target format doesn't support. If the target format is JSON (no comments), these must be documented in the report. It is more important to produce a correctly-formatted config file than to preserve unmappable metadata inline.

**Disabled servers:** Document how disabled servers are handled for each target — whether the target supports a `disabled` flag, whether to comment them out, or whether to omit them entirely. Record this decision in the field mapping.

### 5. Generate Target Config

For each MCP server entry in the source `servers` object:

1. **Backup first.** Before modifying any existing target config file, copy it to a timestamped backup (e.g., `settings.json.bak.20260301T1423`).
2. **Double-buffer edits.** Write to a `.tmp` file first. Only after verification, atomically replace the original (`Move-Item -Force` on Windows).
3. **Merge, don't overwrite.** If the target config file already exists, read it first and **merge** the new MCP server entries without overwriting other settings.
   - If an existing entry has the same name and identical fields, **skip it** (avoid duplication).
   - When comparing fields for equality, **ignore the `disabled` flag** — it is not a substantive field. If all other fields match, skip the entry but update its `disabled` state to match the source (the source is the canonical authority). Log any disabled-state changes in the report.
   - If an existing entry has the same name but different substantive fields (anything other than `disabled`), **preserve the existing entry** and rename the new one (e.g., append `-1`) to avoid overwriting.
4. **Resolve secrets.** If environment variables in `env` contain placeholder values, resolve them from `.api_keys` and insert using the target's env var mechanism. Apply this priority order:
   1. **Env var passthrough** — if the target supports `env` blocks natively (most MCP clients do), pass the variable name through and let the runtime resolve it. This is the safest option.
   2. **Env var reference syntax** — if the target uses inline references (e.g., `${VAR_NAME}`), use that syntax.
   3. **Inline value at user-wide location** — write the resolved value directly only if the target config is user-wide, not version-controlled, and not synced.
   4. **Never in version-controlled files** — if none of the above apply, insert a placeholder (e.g., `<SET_YOUR_API_KEY>`) and document in the report.

   If a resolved secret value is empty or whitespace-only, log a WARNING in the report but do not block generation.
5. **Pin package versions.** When translating `command`/`args` that include package references (e.g., `npx <package>@latest`):
   - If the source entry has a `version` field, use the pinned version from the source (e.g., `npx @modelcontextprotocol/server-foo@0.0.1`) instead of `@latest`.
   - If no `version` field is present, keep `@latest`.
   - Document the version used for each server in the conversion report.
6. **Verify after swap.** Read back the target file and run these checks:
   - Config file parses without errors (JSON/YAML/TOML as appropriate)
   - All required fields per server entry are present
   - Transport type values are valid for the target
   - Env var references resolve (or use correct placeholder syntax)
   - No malformed entries were emitted (all skipped entries are logged)
   If verification fails, restore from backup immediately.

**Re-run behavior:** If target config already contains entries from a prior conversion, the merge logic (substep 3) handles deduplication. Include a diff summary of what changed in the conversion report.

Write the generated config to the target's **user-wide** location for the detected environment.

### 6. Generate Conversion Report

After completion, generate a conversion report directory at `docs/reports/<target>/` (e.g., `docs/reports/claude-code-mcp/`, `docs/reports/factory-droid-mcp/`). This allows multiple report files per target if needed.

The primary report file is always named `conversion-report.md`. It should contain:

- Target client name and date
- Source and target formats
- List of generated/modified MCP server entries
- Target config file location used
- Field mapping applied (including transport type mapping)
- How disabled servers were handled (including any disabled-state updates during merge)
- How metadata fields (`version`, `gallery`) were preserved
- How secrets/env vars were resolved and injected (mechanism used, not actual values)
- Skipped server entries — server name, missing/invalid fields, and WARNING details
- Package version pinning decisions per server (pinned version vs `@latest`)
- Transport type mapping — which HTTP transport was selected and why; alternatives noted
- Merge decisions (skipped duplicates, renamed conflicts)
- Diff summary of changes (for re-runs)
- Secret resolution warnings (empty or unresolved values)
- Any issues encountered and whether they were resolved

Reference existing reports for format: [docs/reports/](../../../docs/reports/)

### 7. Quality Gate

Run these checks before considering the conversion complete. If any check fails, fix the issue before finishing.

- [ ] Every source MCP server has a corresponding entry in target config (or is documented as skipped with reason and WARNING)
- [ ] Required fields (server name, transport type, command/args or URL) are present for each entry
- [ ] Malformed source entries were skipped with WARNINGs logged in the report
- [ ] Transport types are correctly mapped to target equivalents (using most compatible HTTP transport from step 3)
- [ ] Disabled servers are handled per the documented strategy (disabled-state updates logged)
- [ ] Secrets are resolved via the target's mechanism (not raw values in version-controlled files)
- [ ] Empty/unresolved secrets have WARNINGs logged in the report
- [ ] Package versions are pinned from source `version` field where present; `@latest` used only when absent
- [ ] Existing config entries were preserved (merge, not overwrite; disabled-state compared separately)
- [ ] Target config file is at the correct user-wide location for the detected environment
- [ ] Backup exists for the modified config file
- [ ] Conversion report exists at `docs/reports/<target>/conversion-report.md`
- [ ] Report includes merge decisions, transport mappings, disabled-server handling, skipped entries, and version pinning

## Known Target Types

The [generate-target-mcp-servers.md](../../../generate-target-mcp-servers.md) task guide maintains a "Learned target type index" that caches previously discovered target formats. Step 3 checks this cache first — if a matching entry exists, it is used directly without re-fetching docs. If no entry exists, the skill discovers the format via web fetch and then caches it for future runs.
