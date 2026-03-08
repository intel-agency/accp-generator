---
name: generate-target-model-providers
description: "Translate source model provider YAML definitions into a target client's custom model/BYOK config format. Use when: converting model providers to Zed Editor, Factory Droid, OpenCode, or other targets; generating target model provider configs; migrating BYOK setups cross-platform; building field mappings from source to target format."
argument-hint: "Target client name or docs URL (e.g., 'Zed Editor', 'Factory Droid', 'OpenCode')"
tools:
  - read
  - edit
  - search
  - command
  - fetch
---

# Generate Target Client Model Providers

Translate source model provider definitions (provider-centric YAML files) into a target client's custom model provider / BYOK configuration format, then place them at the target's user-wide config location.

## When to Use

- Converting `.source/model-providers/providers/*.yaml` files to a new target client format
- Re-running a conversion after source provider definitions have been updated
- Adding support for a new target client type
- Verifying or repairing a previous conversion

## Procedure

### 1. Detect Environment

Detect whether the source is being run from **Windows** or **Linux/WSL**. Record this as the target environment — target files will be placed at the target's user-wide location for this same environment.

### 2. Identify Source Files

Read all provider YAML files from `.source/model-providers/providers/` (hardcoded per repo convention — update here if the repo restructures).

Each file describes one provider with a provider-centric schema:

- Provider-level: `name`, `id`, `description`, `website`, `access_type`, `api_key_var`
- Endpoint-level: `base_url`, `compatibility` (`openai` or `anthropic`)
- Model-level: `id`, `display_name`, `max_output_tokens`, `image_support`

Skip provider files whose `models` lists are empty (stub/TODO providers).

If a source file has malformed YAML or cannot be parsed, **skip it**, log the error, and continue with the remaining files. Include skipped files and error details in the conversion report.

**Load API keys:** Read the `.api_keys` file at `.source/model-providers/.api_keys` to resolve `api_key_var` references. Each line is a `NAME=VALUE` pair. **Never** write raw API key values into version-controlled files.

Reference: [Source model providers directory](../../../.source/model-providers/providers/)

### 3. Discover Target Format

Given the target client name or docs URL:

1. **Check the learned target index first.** Look in [generate-target-model-providers.md](../../../generate-target-model-providers.md) under "Learned target type index" for a cached entry matching the target. If found, use that cached information and skip to step 4.
2. **If no cached entry exists, discover via web fetch.** Use web fetch tools to locate the target's documentation site **non-interactively** (do not ask the user for URLs). Search for and recursively follow documentation links to find the section on custom model providers, BYOK, or custom API endpoints. Extract:
   - User-wide config location (for both Windows and Linux/WSL when documented)
   - File format (JSON, YAML, TOML, etc.) and the specific key/section for model providers
   - Valid fields for each model provider entry
   - Provider protocol types supported (OpenAI-compatible, Anthropic, custom, etc.)
   - API key storage mechanism (inline, env var reference, credential store, etc.)
3. **Cache the discovery.** Record the newly discovered target type as a new subsection in the "Learned target type index" of [generate-target-model-providers.md](../../../generate-target-model-providers.md), including the documentation URL, environment, and all extracted details. This prevents re-fetching on future runs.

**If web fetch fails** (rate limited, docs moved, site down), **stop the entire run** — the target format is a hard dependency. Report the failure clearly with the URL attempted and the error received.

### 4. Build Field Mapping

The source schema is **provider-centric** (provider → endpoints → models). Most targets are **model-centric** (flat list of model entries). The typical transformation flattens the hierarchy:

| Source (YAML) | Target | Transformation |
|---|---|---|
| `endpoints[].base_url` | *(target's base URL field)* | *(per-endpoint)* |
| `endpoints[].compatibility` | *(target's provider/protocol type)* | *(openai → target's OAI-compatible type; anthropic → target's Anthropic type)* |
| `endpoints[].models[].id` | *(target's model ID field)* | *(direct map)* |
| `endpoints[].models[].display_name` | *(target's display name field)* | *(compose as `"<display_name> [<provider.name>]"` unless target has own convention)* |
| `endpoints[].models[].max_output_tokens` | *(target's max tokens field)* | *(direct map)* |
| `endpoints[].models[].image_support` | *(target's capabilities field)* | *(may be inverted, e.g., `noImageSupport`)* |
| `api_key_var` → resolved value | *(target's API key field/mechanism)* | *(use target's env var syntax or credential store)* |
| `name`, `description`, `website`, `access_type` | *(comment/metadata or omitted)* | *(preserve if target supports; otherwise document in report)* |

**CRITICAL: Lossless translation.** All source information must appear in the target output. Use these priority tiers:

- **Required (must appear):** `base_url`, `model.id`, `compatibility`/protocol type, API key.
- **Best-effort (map if target supports):** `display_name`, `max_output_tokens`, `image_support`.
- **Document-only (preserve as comments or in report):** `name`, `description`, `website`, `access_type`, `version`. If the target format is JSON (no comments), these must go in the report.

**Multi-endpoint providers:** Providers with multiple endpoints require separate target entries per endpoint (one entry per endpoint per model). Document this flattening in the field mapping.

### 5. Generate Target Config

For each provider file, for each endpoint, for each model:

1. **Backup first.** Before modifying any existing target config file, copy it to a timestamped backup (e.g., `settings.json.bak.20260301T1423`).
2. **Double-buffer edits.** Write to a `.tmp` file first. Only after verification, atomically replace the original (`Move-Item -Force` on Windows).
3. **Merge, don't overwrite.** If the target config file already exists, read it first and **merge** the new model provider entries without overwriting other settings.
   - If an existing entry has the same model ID and identical fields, **skip it** (avoid duplication).
   - If an existing entry has the same model ID but different fields, **preserve the existing entry** and rename the new one to avoid overwriting.
4. **Resolve API keys.** Look up `api_key_var` in the loaded `.api_keys` data. Insert the resolved key using the target's expected mechanism:
   - Env var reference syntax (e.g., `${VAR_NAME}`, `{env:VAR_NAME}`) — preferred
   - Inline value — only if target config is at a user-wide location (not version-controlled)
   - Credential store command — if target supports it
5. **Map protocol types.** Map `compatibility` to the target's provider type:
   - `openai` → target's OpenAI-compatible / generic chat completion type
   - `anthropic` → target's Anthropic type (if supported; otherwise fall back to OpenAI-compatible if the endpoint proxies to OpenAI format)
6. **Verify after swap.** Read back the target file and run these checks:
   - Config file parses without errors (JSON/YAML/TOML as appropriate)
   - All required fields per model entry are present
   - Protocol type values are valid for the target
   - API key references resolve (or use correct placeholder syntax)
   - Boolean inversions are correct (e.g., `image_support: true` → `noImageSupport: false`)
   If verification fails, restore from backup immediately.

**Re-run behavior:** If target config already contains entries from a prior conversion, the merge logic (substep 3) handles deduplication. Include a diff summary of what changed in the conversion report.

Write the generated config to the target's **user-wide** location for the detected environment.

### 6. Generate Conversion Report

After completion, generate a conversion report directory at `docs/reports/<target>/` (e.g., `docs/reports/zed-editor-providers/`, `docs/reports/factory-droid-providers/`). This allows multiple report files per target if needed.

The primary report file is always named `conversion-report.md`. It should contain:

- Target client name and date
- Source and target formats
- List of generated/modified model provider entries
- Target config file location used
- Field mapping applied (including protocol type mapping and flattening strategy)
- How API keys were resolved and injected (mechanism used, not the actual values)
- How provider metadata (`name`, `description`, `website`, `access_type`) was preserved
- Merge decisions (skipped duplicates, renamed conflicts)
- Diff summary of changes (for re-runs)
- Skipped source files and errors (if any)
- Any other issues encountered and whether they were resolved

Reference existing reports for format: [docs/reports/](../../../docs/reports/)

### 7. Quality Gate

Run these checks before considering the conversion complete. If any check fails, fix the issue before finishing.

- [ ] Every source provider/endpoint/model combo has a corresponding entry in target config (or is logged as skipped with reason)
- [ ] Required fields (`base_url`, `model.id`, protocol type, API key) are present for each entry
- [ ] Protocol types are correctly mapped to target equivalents
- [ ] API keys are resolved via the target's mechanism (not raw values in version-controlled files)
- [ ] Boolean inversions are correct (e.g., `image_support` ↔ `noImageSupport`)
- [ ] Display names follow the target's convention or use `"<display_name> [<provider.name>]"` composite
- [ ] Existing config entries were preserved (merge, not overwrite)
- [ ] Target config file is at the correct user-wide location for the detected environment
- [ ] Backup exists for the modified config file
- [ ] Conversion report exists at `docs/reports/<target>/conversion-report.md`
- [ ] Report documents API key handling (mechanism only, not actual values)

## Known Target Types

The [generate-target-model-providers.md](../../../generate-target-model-providers.md) task guide maintains a "Learned target type index" that caches previously discovered target formats. Step 3 checks this cache first — if a matching entry exists, it is used directly without re-fetching docs. If no entry exists, the skill discovers the format via web fetch and then caches it for future runs.
