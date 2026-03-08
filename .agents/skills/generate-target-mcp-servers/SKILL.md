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

If an `.api_keys` file exists at `.source/mcp-servers/Code - Insiders/.api_keys`, load the `NAME=VALUE` pairs for secret resolution.

Reference: [Source MCP servers directory](../../../.source/mcp-servers/)

### 3. Discover Target Format

Given the target client name or docs URL:

1. **Check the learned target index first.** Look in [generate-target-mcp-servers.md](../../../generate-target-mcp-servers.md) under "Learned target type index" for a cached entry matching the target. If found, use that cached information and skip to step 4.
2. **If no cached entry exists, discover via web fetch.** Use web fetch tools to locate the target's documentation site **non-interactively** (do not ask the user for URLs). Search for and recursively follow documentation links to find the section on MCP server configuration, MCP integration, or tool server setup. Extract:
   - User-wide MCP config location (for both Windows and Linux/WSL when documented)
   - File format (JSON, YAML, TOML, etc.) and the specific key/section for MCP servers
   - Valid fields for each MCP server entry
   - Transport types supported (`stdio`, `http`, `sse`, `streamable-http`, etc.)
   - Environment variable / secrets mechanism for MCP servers
3. **Cache the discovery.** Record the newly discovered target type as a new subsection in the "Learned target type index" of [generate-target-mcp-servers.md](../../../generate-target-mcp-servers.md), including the documentation URL, environment, and all extracted details. This prevents re-fetching on future runs.

**If web fetch fails** (rate limited, docs moved, site down), **stop the entire run** — the target format is a hard dependency. Report the failure clearly with the URL attempted and the error received.

### 4. Build Field Mapping

Create a mapping between each source field and the most appropriate target field:

| Source (VS Code mcp.json) | Target | Transformation |
|---------------------------|--------|----------------|
| Server name (key) | *(target's server name/id)* | *(document rule)* |
| `type` | *(target's transport type)* | *(map: stdio→stdio, http→sse/streamable-http/etc.)* |
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
   - If an existing entry has the same name but different fields, **preserve the existing entry** and rename the new one (e.g., append `-1`) to avoid overwriting.
4. **Resolve secrets.** If environment variables are present, resolve placeholder values from `.api_keys` and insert using the target's env var mechanism. **Never** write raw secrets into version-controlled files.
5. **Verify after swap.** Read back the target file and run these checks:
   - Config file parses without errors (JSON/YAML/TOML as appropriate)
   - All required fields per server entry are present
   - Transport type values are valid for the target
   - Env var references resolve (or use correct placeholder syntax)
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
- How disabled servers were handled
- How metadata fields (`version`, `gallery`) were preserved
- How secrets/env vars were resolved and injected
- Merge decisions (skipped duplicates, renamed conflicts)
- Diff summary of changes (for re-runs)
- Any issues encountered and whether they were resolved

Reference existing reports for format: [docs/reports/](../../../docs/reports/)

### 7. Quality Gate

Run these checks before considering the conversion complete. If any check fails, fix the issue before finishing.

- [ ] Every source MCP server has a corresponding entry in target config (or is documented as skipped with reason)
- [ ] Required fields (server name, transport type, command/args or URL) are present for each entry
- [ ] Transport types are correctly mapped to target equivalents
- [ ] Disabled servers are handled per the documented strategy
- [ ] Secrets are resolved via the target's mechanism (not raw values in version-controlled files)
- [ ] Existing config entries were preserved (merge, not overwrite)
- [ ] Target config file is at the correct user-wide location for the detected environment
- [ ] Backup exists for the modified config file
- [ ] Conversion report exists at `docs/reports/<target>/conversion-report.md`
- [ ] Report includes merge decisions, transport mappings, and disabled-server handling

## Known Target Types

The [generate-target-mcp-servers.md](../../../generate-target-mcp-servers.md) task guide maintains a "Learned target type index" that caches previously discovered target formats. Step 3 checks this cache first — if a matching entry exists, it is used directly without re-fetching docs. If no entry exists, the skill discovers the format via web fetch and then caches it for future runs.
