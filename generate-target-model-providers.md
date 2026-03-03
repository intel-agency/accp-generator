# Generate Target Client Model Providers

Read the source model provider definitions and translate them into the target client's specific format, then write them to the target's custom model provider location.

## Goal

Your goal is to create corresponding model provider entries in the target's format and place them at the target's **user-wide** custom model provider location in the same environment as the source. First detect whether the source is being run from **Windows** or **Linux/WSL**, record that as the target environment, and then use the target's user-wide location for that same environment. Use the web fetch tools to discover the target docs and recursively follow any documentation links you find along the way, executing non-interactively without user intervention.

## Architecture: Sources vs Targets

- **Sources** = the actual model providers (cloud services / subscriptions that expose API endpoints). These are stored as provider-centric YAML files in `.source/model-providers/providers/`.
- **Targets** = inference clients that consume these endpoints via BYOK, OAuth proxies, or other mechanisms (e.g. Factory Droid, Zed Editor, OpenCode, Claude Code, VS Code Copilot Chat, Kilo Code, etc.).

Every target client is **generated from** the provider sources — no target's config file should be used as a source.

## Source model provider files

Location: `.source/model-providers/providers/*.yaml`
Format: YAML (one file per provider)
Secrets: `.source/model-providers/.api_keys` (gitignored env-file)

### Source format reference

Each file describes one provider (a cloud service you have access to). The schema is:

```yaml
name: <Human-readable provider name>
id: <kebab-case identifier, matches filename>
description: <What this provider is>
website: <Provider URL>
access_type: <subscription | free-tier | trial | api-key>
api_key_var: <ENV_VAR_NAME referencing .api_keys>

endpoints:
  - base_url: <Full API endpoint URL>
    compatibility: <openai | anthropic>
    models:
      - id: <model identifier sent to the API>
        display_name: <Human-readable label>
        max_output_tokens: <number>
        image_support: <true | false>
```

#### Field reference

| Field | Level | Type | Description |
|---|---|---|---|
| `name` | provider | string | Human-readable provider name. |
| `id` | provider | string | Kebab-case ID (matches filename without `.yaml`). |
| `description` | provider | string | What this provider is and how you access it. |
| `website` | provider | string | Provider's URL. |
| `access_type` | provider | string | `subscription`, `free-tier`, `trial`, or `api-key`. |
| `api_key_var` | provider | string | Env var name in `.api_keys` holding the API secret. |
| `endpoints` | provider | list | API endpoints this provider exposes. |
| `base_url` | endpoint | string | Full API base URL. |
| `compatibility` | endpoint | string | Protocol type: `openai` or `anthropic`. |
| `models` | endpoint | list | Models available at this endpoint. |
| `id` | model | string | Model identifier sent in API requests. |
| `display_name` | model | string | Human-readable label. |
| `max_output_tokens` | model | number | Maximum output token limit. |
| `image_support` | model | boolean | Whether the model accepts image inputs (default: `false`). |

### Source providers inventory

| # | Provider | ID | Endpoints | Access | API Key Var |
|---|---|---|---|---|---|
| 1 | Z.AI Coding Plan | `zai-coding-plan` | anthropic + openai | subscription | `ZAI_CODING_PLAN_API_KEY` |
| 2 | Google AI Studio | `google-ai-studio` | openai | free-tier | `GOOGLE_AI_STUDIO_API_KEY` |
| 3 | ChatGPT / Codex | `chatgpt-codex` | openai | subscription | `OPENAI_API_KEY` |
| 4 | OpenRouter | `openrouter` | openai | free-tier | `OPENROUTER_API_KEY` |
| 5 | Alibaba Model Studio | `alibaba-model-studio` | openai | trial | `ALIBABA_MODEL_STUDIO_API_KEY` |
| 6 | Mistral AI | `mistral` | openai | free-tier | `MISTRAL_API_KEY` |
| 7 | Kimi (Moonshot AI) | `kimi` | openai | api-key | `KIMI_CODING_API_KEY` |
| 8 | OVHCloud AI Agents | `ovhcloud` | openai | api-key | `OVHCLOUD_API_KEY` |
| 9 | GitHub Copilot | `github-copilot` | openai | subscription | `GITHUB_TOKEN` |

### API key handling

API keys are stored in a gitignored env-file at:

```
.source/model-providers/.api_keys
```

Format: one `NAME=VALUE` pair per line (shell env-file style). Example:

```
ZAI_CODING_PLAN_API_KEY=<actual-key-value>
KIMI_K25_OLLAMA_API_KEY=<actual-key-value>
```

Each provider YAML references its key by variable name in `api_key_var`. When generating target model providers:

1. **Read** the `.api_keys` file to resolve variable names to actual secret values.
2. **Insert** the resolved key value into the target's `apiKey` (or equivalent) field.
3. **Never** write raw API key values into any file that will be committed to version control. If the target stores config in a file that is version-controlled, use the target's recommended secrets mechanism (environment variables, credential store, etc.) instead.
4. If the target has no secrets mechanism, write the key directly into the target config file **only if that file is in a user-wide location** (not in a workspace/repo directory).

## Target model provider location and format

Given the target (name/version or vendor docs URL), automatically search the web for the target's documentation site **without asking the user for URLs**. Use the web fetch tools to locate and read the documentation, then search for the section on custom model providers, BYOK (bring your own key), or custom API endpoints. In that section you need to find:

0. **Environment-specific locations:** determine and record the target's user-wide model-provider config location for **Windows** and for **Linux/WSL** when both are documented.
1. **Location:** the user-wide config file path and the specific key/section within it where custom model providers are defined (NOT local workspace directory unless it is the only option)
2. **File format:** JSON, YAML, TOML, or other config format
3. **Valid fields** for each model provider entry (model name, API base URL, API key, provider type, max tokens, display name, etc.)
4. **Provider protocol types** supported (OpenAI-compatible, Anthropic, custom, etc.)
5. **API key storage mechanism:** how the target expects API keys to be supplied (inline in config, environment variable reference, credential store, etc.)

After reading all of this information (gathered non-interactively via web fetch tools):

1. Create a field mapping from each source field to the most appropriate target field.
2. Document the mapping, including how each source field translates and how unmapped fields are preserved (e.g., as comments or extra metadata) to ensure a lossless translation.
3. Document the target's API key mechanism and how source `.api_keys` values should be resolved and injected.

### Source → Target field mapping (general pattern)

The source schema is provider-centric (provider → endpoints → models). Most targets are model-centric (flat list of model entries). The typical flattening is:

| Source (YAML) | Target (typical) | Notes |
|---|---|---|
| `endpoints[].base_url` | `baseUrl` / `api_url` | Per-endpoint |
| `endpoints[].compatibility` | `provider` / protocol type | `openai` → target's OpenAI-compatible type; `anthropic` → target's Anthropic type |
| `endpoints[].models[].id` | `model` / `name` | Model identifier |
| `endpoints[].models[].display_name` | `displayName` / `display_name` | Human-readable label |
| `endpoints[].models[].max_output_tokens` | `maxOutputTokens` / `max_output_tokens` | Token limit |
| `endpoints[].models[].image_support` | varies | Inverted from old `noImageSupport`; map to target's capabilities field |
| `api_key_var` → resolved value | `apiKey` / env var / keychain | Per target's secrets mechanism |
| `name` | preserved as comment/metadata | Provider display name for human context |

## Generate Target Model Providers

For each provider YAML file in `.source/model-providers/providers/`, iterate over its endpoints and models to generate corresponding entries in the target's format using the field mapping.

**IMPORTANT** The translation must be lossless — do not leave out any info from the source entry. Every source field must map to a target field or be preserved as a comment/metadata annotation. Skip provider files whose `models` lists are empty (stub/TODO providers).

**CRITICAL — Backup and safe-write procedure:**

1. **Backup first.** Before making any changes, copy the target file to a timestamped backup (e.g., `settings.json.bak.20260301T1423`). Never modify the original without a backup in place.
2. **Double-buffer edits.** Copy the target file to a temporary working file (e.g., `settings.json.tmp` in the same directory). Apply all changes to the temp copy. Only after the temp copy is verified correct, atomically replace the original with the temp copy (e.g., `Move-Item -Force` on Windows). This prevents a half-written or corrupt file if the process is interrupted.
3. **Verify after swap.** After the swap, read back the target file and confirm it parses correctly. If verification fails, restore from the backup immediately.

**Steps:**

1. Read the `.api_keys` file (`./source/model-providers/.api_keys`) to load `NAME=VALUE` pairs into memory.
2. Read each `providers/*.yaml` file; skip any with empty `models` lists.
3. For each provider file, for each endpoint, for each model:
   a. Map all source fields to target fields using the field mapping.
   b. Resolve the `api_key_var` to its actual value from the loaded `.api_keys` data.
   c. Insert the resolved API key into the target's expected location (inline field, env var reference, or credential store command — per target docs).
   d. Map `compatibility` (`openai`, `anthropic`) to the target's provider type:
      - `openai` → target's OpenAI-compatible / generic chat completion type
      - `anthropic` → target's Anthropic type (if supported; otherwise fall back to OpenAI-compatible if the endpoint proxies to OpenAI format)
   e. Compose a display name: `"<model.display_name> [<provider.name>]"` unless the target has its own naming convention.
4. Write the generated config to the target's **user-wide** location in the **same environment as the source** (Windows source → Windows target location, Linux/WSL source → Linux/WSL target location), not the local workspace directory.
5. If the target config file already exists, **merge** the new model providers into the existing file without overwriting other settings. Read the existing file first, add/update only the model provider entries, and write back.

If validation or checks are required, ask the user before running any commands.

Use Windows-first (PowerShell) guidance when providing any shell instructions.

## Learned target type index

Maintain an index of learned target types in this section. Add a new subsection per target type as you learn its user-wide location, file format, and valid fields. Append new subsections in chronological order so the most recently learned target types are last. Include the URL of the target type's documentation where the information was found in each index entry.

Record the **environment** for each learned entry (`Windows` or `Linux/WSL`). If paths differ by environment, create separate entries for the same target type (for example, one Windows entry and one Linux/WSL entry) rather than collapsing them into a single path.

### Zed Editor (Windows)

- **Documentation:** <https://zed.dev/docs/ai/llm-providers> , <https://zed.dev/docs/reference/all-settings>
- **Environment:** Windows
- **User-wide config file:** `%APPDATA%\Zed\settings.json`
- **File format:** JSONC (JSON with comments, trailing commas allowed)
- **Config key:** `language_models` object at root level
- **Provider sections:**
  - `language_models.anthropic` — native Anthropic support with `api_url` and `available_models[]`
  - `language_models.openai_compatible.<ProviderName>` — OpenAI-compatible endpoints with `api_url` and `available_models[]`
  - `language_models.ollama` — Ollama with `api_url` and `available_models[]`
  - `language_models.openai`, `language_models.google`, `language_models.deepseek` — other built-in providers
- **Anthropic model fields:** `name`, `display_name`, `max_tokens`, `max_output_tokens`, `cache_configuration`, `tool_override`, `mode`
- **OpenAI-compatible model fields:** `name`, `display_name`, `max_tokens`, `max_output_tokens`, `max_completion_tokens`, `capabilities` (`tools`, `images`, `parallel_tool_calls`, `prompt_cache_key`, `chat_completions`)
- **API key mechanism:**
  - Anthropic: OS keychain (via Agent Panel settings UI) or `ANTHROPIC_API_KEY` env var
  - OpenAI-compatible: `<PROVIDER_NAME>_API_KEY` env var (provider name uppercased, special chars → underscore)
  - Not stored inline in settings.json

### Zed Editor (Linux/WSL)

- **Documentation:** <https://zed.dev/docs/ai/llm-providers> , <https://zed.dev/docs/reference/all-settings>
- **Environment:** Linux/WSL
- **User-wide config file:** `~/.config/zed/settings.json`
- **File format:** Same as Windows entry above
- **Config key / Provider sections / Model fields / API key mechanism:** Same as Windows entry above

### OpenCode (Windows)

- **Documentation:** <https://opencode.ai/docs/config/> , <https://opencode.ai/docs/providers/>
- **Environment:** Windows
- **User-wide config file:** `%USERPROFILE%\.config\opencode\opencode.json`
- **File format:** JSON or JSONC (JSON with Comments)
- **Config key:** `provider` object at root level
- **Custom provider fields:**
  - `npm` — AI SDK package name (`@ai-sdk/openai-compatible` for OpenAI-compatible, `@ai-sdk/anthropic` for Anthropic)
  - `name` — Human-readable display name in UI
  - `options.baseURL` — API endpoint base URL
  - `options.apiKey` — API key (supports `{env:VAR_NAME}` syntax for env var substitution)
  - `options.headers` — Custom HTTP headers
  - `models` — Map of model ID → model config
- **Model fields:**
  - `name` — Display name in model selector
  - `limit.context` — Max input tokens
  - `limit.output` — Max output tokens
  - `id` — Override model identifier (for ARN/custom IDs)
  - `options` — Model-specific provider options
- **API key mechanism:**
  - `{env:VAR_NAME}` syntax in `options.apiKey` for environment variable references
  - `/connect` command stores credentials in `~/.local/share/opencode/auth.json`
  - `{file:path}` syntax for reading keys from separate files
  - Inline values supported in user-wide config (not version-controlled)
- **Provider protocol mapping:**
  - `openai` (source) → `npm: "@ai-sdk/openai-compatible"` with custom `baseURL`
  - `anthropic` (source) → `npm: "@ai-sdk/anthropic"` with custom `baseURL`
- **Notes:**
  - No direct `image_support` / `noImageSupport` field for custom models; not mappable
  - Source `description`, `website`, `access_type` have no target equivalent; omitted (not preservable as comments in JSON mode)
  - Multi-endpoint providers require separate custom provider entries (one per endpoint)

### OpenCode (Linux/WSL)

- **Documentation:** <https://opencode.ai/docs/config/> , <https://opencode.ai/docs/providers/> , <https://opencode.ai/docs/windows-wsl>
- **Environment:** Linux/WSL
- **User-wide config file:** `~/.config/opencode/opencode.json`
- **File format:** Same as Windows entry above
- **Config key / Custom provider fields / Model fields / API key mechanism:** Same as Windows entry above
- **Data directory:** `~/.local/share/opencode/`

### Factory Droid (Windows)

- **Documentation:** <https://docs.factory.ai/cli/byok/overview>
- **Environment:** Windows
- **User-wide config file:** `%USERPROFILE%\.factory\settings.json`
- **File format:** JSON
- **Config key:** `customModels` array at root level
- **Custom model fields:**
  - `model` — Model identifier sent to the API (required)
  - `displayName` — Human-readable label in model selector
  - `baseUrl` — API endpoint base URL (required)
  - `apiKey` — API key; supports `${VAR_NAME}` env var syntax (required)
  - `provider` — Protocol type (required): `anthropic`, `openai` (OpenAI Responses API), `generic-chat-completion-api` (OpenAI Chat Completions API)
  - `maxOutputTokens` — Maximum output token limit
  - `noImageSupport` — `true` if model does not accept image inputs (inverted boolean)
  - `extraArgs` — Additional provider-specific arguments (object)
  - `extraHeaders` — Custom HTTP headers (object)
- **Provider protocol mapping:**
  - `openai` (source) → `provider: "generic-chat-completion-api"` (Chat Completions API)
  - `anthropic` (source) → `provider: "anthropic"` (Anthropic Messages API)
  - Note: `"openai"` in Factory Droid means OpenAI **Responses** API (for newest OpenAI models); most OpenAI-compatible endpoints use `"generic-chat-completion-api"`
- **API key mechanism:**
  - `${VAR_NAME}` syntax for environment variable references (preferred)
  - Inline values supported (user-wide location, not version-controlled)
  - No separate credential store or auth file
- **Notes:**
  - Source `image_support` maps to `noImageSupport` (inverted: `true` → `false`, `false` → `true`)
  - Source `description`, `website`, `access_type` have no target equivalent; omitted
  - Multi-endpoint providers require separate customModel entries (one per endpoint per model)
  - Factory auto-generates `id` and `index` fields at runtime; do not include in generated config

### Factory Droid (Linux/WSL)

- **Documentation:** <https://docs.factory.ai/cli/byok/overview>
- **Environment:** Linux/WSL
- **User-wide config file:** `~/.factory/settings.json`
- **File format:** Same as Windows entry above
- **Config key / Custom model fields / Provider protocol mapping / API key mechanism:** Same as Windows entry above

## Conclusion

After each run, generate a markdown report detailing the conversion process. Include:

- A list of generated/modified model provider entries
- The target config file location used
- The field mapping applied
- A summary of how API keys were resolved and injected
- Any issues encountered and whether they were resolved or still persist
