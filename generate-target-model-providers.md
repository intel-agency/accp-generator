# Generate Target Client Model Providers

Use the source custom model provider definitions and translate them from the source format into the target's specific format, then add them to the target's custom model provider location.

## Goal

Your goal is to create corresponding model provider entries in the target's format and place them at the target's user-wide custom model provider location in the **same environment as the source**. First detect whether the source is being run from **Windows** or **Linux/WSL**, record that as the target environment, and then use the target's user-wide location for that same environment. Use the web fetch tools to discover the target docs and recursively follow any documentation links you find along the way, executing non-interactively without user intervention.

## Source model provider files

Location: <./.source/model-providers/.factory/>
Format: Factory CLI settings JSON (`settings.json` with a `customModels` array)

### Source format reference

The source is a Factory CLI `settings.json` file. Model providers are defined in the `customModels` array. Each entry has the following fields:

| Field | Type | Description |
|---|---|---|
| `model` | string | Upstream model identifier sent to the provider API (e.g., `glm-4.7-flash`). |
| `id` | string | Factory-internal custom model ID (format: `custom:<DisplaySlug>-<Index>`). |
| `index` | number | Disambiguation index when multiple entries share the same base model name. |
| `baseUrl` | string | Provider API endpoint URL. |
| `apiKey` | string | **Placeholder variable name** referencing a secret in the `.api_keys` file (see _API key handling_ below). |
| `displayName` | string | Human-readable label shown in the UI. |
| `maxOutputTokens` | number | Maximum output token limit for the model. |
| `noImageSupport` | boolean | Whether the model lacks image/vision input support. |
| `provider` | string | Provider protocol type (`anthropic`, `generic-chat-completion-api`, etc.). |

### Source model providers inventory

The following model providers are defined in the source file:

| # | displayName | model | provider | baseUrl | maxOutputTokens | apiKey variable |
|---|---|---|---|---|---|---|
| 1 | GLM-4.5 Air [Z.AI Coding Plan] - Anthropic | `glm-4.5-air` | `anthropic` | `https://api.z.ai/api/anthropic` | 98304 | `ZAI_CODING_PLAN_API_KEY` |
| 2 | GLM-4.5 AirX [Z.AI Coding Plan] - Anthropic | `glm-4.5-airX` | `anthropic` | `https://api.z.ai/api/anthropic` | 98304 | `ZAI_CODING_PLAN_API_KEY` |
| 3 | GLM-4.7 Flash [Z.AI Coding Plan] - Anthropic | `glm-4.7-flash` | `anthropic` | `https://api.z.ai/api/anthropic` | 131072 | `ZAI_CODING_PLAN_API_KEY` |
| 4 | GLM-4.7 FlashX [Z.AI Coding Plan] - Anthropic | `glm-4.7-flashX` | `anthropic` | `https://api.z.ai/api/anthropic` | 131072 | `ZAI_CODING_PLAN_API_KEY` |
| 5 | GLM-4.7 [Z.AI Coding Plan] - Anthropic | `glm-4.7` | `anthropic` | `https://api.z.ai/api/anthropic` | 131072 | `ZAI_CODING_PLAN_API_KEY` |
| 6 | GLM-4.7 [Z.AI Coding Plan] - Openai | `glm-4.7` | `generic-chat-completion-api` | `https://api.z.ai/api/coding/paas/v4` | 131072 | `ZAI_CODING_PLAN_API_KEY` |
| 7 | GLM-5 [Z.AI Coding Plan] - Anthropic | `glm-5` | `anthropic` | `https://api.z.ai/api/anthropic` | 131072 | `ZAI_CODING_PLAN_API_KEY` |
| 8 | Kimi K2.5 Direct Cloud - Ollama | `kimi-k2.5:cloud` | `generic-chat-completion-api` | `https://ollama.com/v1/` | 4000 | `KIMI_K25_OLLAMA_API_KEY` |

### API key handling

API keys are **never stored in the source `settings.json`**. Instead, each model entry's `apiKey` field contains a **placeholder variable name** (e.g., `ZAI_CODING_PLAN_API_KEY`). The actual secret values are stored in a separate `.api_keys` file at:

```
.source/model-providers/.factory/.api_keys
```

Format: one `NAME=VALUE` pair per line (shell env-file style). Example:

```
ZAI_CODING_PLAN_API_KEY=<actual-key-value>
KIMI_K25_OLLAMA_API_KEY=<actual-key-value>
```

When generating target model providers:

1. **Read** the `.api_keys` file to resolve placeholder names to actual secret values.
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
3. Document the target's API key mechanism and how source `.api_keys` placeholder values should be resolved and injected.

## Generate Target Model Providers

For each model provider entry in the source `customModels` array, generate a corresponding entry in the target's format using the field mapping from the previous section.

**IMPORTANT** The translation must be lossless—do not leave out any info from the source entry. Every source field must map to a target field or be preserved as a comment/metadata annotation.

**Steps:**

1. Read the source `.api_keys` file to load the `NAME=VALUE` pairs into memory.
2. Read the source `settings.json` and parse the `customModels` array.
3. For each model entry:
   a. Map all source fields to target fields using the field mapping.
   b. Resolve the `apiKey` placeholder variable name to its actual value from the loaded `.api_keys` data.
   c. Insert the resolved API key into the target's expected location (inline field, env var reference, or credential store command—per target docs).
   d. If the source `provider` value (`anthropic`, `generic-chat-completion-api`) does not have a direct equivalent in the target, use the closest match and document the mapping choice.
4. Write the generated config to the target's **user-wide** location in the **same environment as the source** (Windows source -> Windows target location, Linux/WSL source -> Linux/WSL target location), not the local workspace directory.
5. If the target config file already exists, **merge** the new model providers into the existing file without overwriting other settings. Read the existing file first, add/update only the model provider entries, and write back.

If validation or checks are required, ask the user before running any commands.

Use Windows-first (PowerShell) guidance when providing any shell instructions.

## Learned target type index

Maintain an index of learned target types in this section. Add a new subsection per target type as you learn its user-wide location, file format, and valid fields. Append new subsections in chronological order so the most recently learned target types are last. Include the URL of the target type's documentation where the information was found in each index entry.

Record the **environment** for each learned entry (`Windows` or `Linux/WSL`). If paths differ by environment, create separate entries for the same target type (for example, one Windows entry and one Linux/WSL entry) rather than collapsing them into a single path.

## Conclusion

After each run, generate a markdown report detailing the conversion process. Include:

- A list of generated/modified model provider entries
- The target config file location used
- The field mapping applied
- A summary of how API keys were resolved and injected
- Any issues encountered and whether they were resolved or still persist
