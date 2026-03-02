# Model Provider Conversion Report: Factory CLI → Zed Editor

**Generated:** 2025-07-17
**Source:** Factory CLI `settings.json` (`customModels` array)
**Target:** Zed Editor `settings.json` (`language_models` section)
**Environment:** Windows
**Target config file:** `%APPDATA%\Zed\settings.json` (`C:\Users\nmill\AppData\Roaming\Zed\settings.json`)

---

## Generated/Modified Model Provider Entries

### Anthropic Provider (6 models)

All routed through Z.AI Anthropic-compatible proxy at `https://api.z.ai/api/anthropic`.

| # | Source displayName | Zed name | Zed display_name | max_tokens | max_output_tokens |
|---|---|---|---|---|---|
| 1 | GLM-4.5 Air [Z.AI Coding Plan] - Anthropic | `glm-4.5-air` | GLM-4.5 Air [Z.AI Coding Plan] - Anthropic | 98304 | 98304 |
| 2 | GLM-4.5 AirX [Z.AI Coding Plan] - Anthropic | `glm-4.5-airX` | GLM-4.5 AirX [Z.AI Coding Plan] - Anthropic | 98304 | 98304 |
| 3 | GLM-4.7 Flash [Z.AI Coding Plan] - Anthropic | `glm-4.7-flash` | GLM-4.7 Flash [Z.AI Coding Plan] - Anthropic | 131072 | 131072 |
| 4 | GLM-4.7 FlashX [Z.AI Coding Plan] - Anthropic | `glm-4.7-flashX` | GLM-4.7 FlashX [Z.AI Coding Plan] - Anthropic | 131072 | 131072 |
| 5 | GLM-4.7 [Z.AI Coding Plan] - Anthropic | `glm-4.7` | GLM-4.7 [Z.AI Coding Plan] - Anthropic | 131072 | 131072 |
| 6 | GLM-5 [Z.AI Coding Plan] - Anthropic | `glm-5` | GLM-5 [Z.AI Coding Plan] - Anthropic | 131072 | 131072 |

### OpenAI-Compatible Provider: "Z.AI Coding Plan OpenAI" (1 model)

API endpoint: `https://api.z.ai/api/coding/paas/v4`

| # | Source displayName | Zed name | Zed display_name | max_tokens | max_output_tokens | capabilities |
|---|---|---|---|---|---|---|
| 7 | GLM-4.7 [Z.AI Coding Plan] - Openai | `glm-4.7` | GLM-4.7 [Z.AI Coding Plan] - Openai | 131072 | 131072 | tools:true, images:false, chat_completions:true |

### OpenAI-Compatible Provider: "Kimi K25 Ollama" (1 model)

API endpoint: `https://ollama.com/v1/`

| # | Source displayName | Zed name | Zed display_name | max_tokens | max_output_tokens | capabilities |
|---|---|---|---|---|---|---|
| 8 | Kimi K2.5 Direct Cloud - Ollama | `kimi-k2.5:cloud` | Kimi K2.5 Direct Cloud - Ollama | 4000 | 4000 | tools:true, images:false, chat_completions:true |

---

## Field Mapping

### Anthropic-Protocol Models (Source `provider: "anthropic"` → Zed `language_models.anthropic`)

| Source Field | Target Field | Mapping Notes |
|---|---|---|
| `model` | `name` | Direct: upstream model identifier |
| `displayName` | `display_name` | Direct: human-readable label |
| `maxOutputTokens` | `max_tokens` | Used as context window (best available data from source) |
| `maxOutputTokens` | `max_output_tokens` | Direct: output token limit |
| `baseUrl` | `api_url` (provider-level) | Shared across all models; set at provider level |
| `apiKey` | `ANTHROPIC_API_KEY` env var | Zed reads from OS keychain or env var |
| `provider` | Provider section: `anthropic` | Direct mapping |
| `noImageSupport` | Comment annotation | Zed's anthropic `available_models` schema has no image capability field; preserved as provider-level comment |
| `id` | Comment: `// source_id: ...` | No Zed equivalent; preserved as comment per model |
| `index` | Comment: `// source_index: ...` | No Zed equivalent; preserved as comment per model |

### OpenAI-Compatible Models (Source `provider: "generic-chat-completion-api"` → Zed `language_models.openai_compatible`)

| Source Field | Target Field | Mapping Notes |
|---|---|---|
| `model` | `name` | Direct: upstream model identifier |
| `displayName` | `display_name` | Direct: human-readable label |
| `maxOutputTokens` | `max_tokens` | Used as context window (best available data from source) |
| `maxOutputTokens` | `max_output_tokens` | Direct: output token limit |
| `baseUrl` | `api_url` (provider-level) | Per-provider URL |
| `apiKey` | `<PROVIDER_NAME>_API_KEY` env var | Zed derives env var name from provider key |
| `provider` | Provider section: `openai_compatible` | `generic-chat-completion-api` → `openai_compatible` |
| `noImageSupport` | `capabilities.images` (inverted) | `noImageSupport: true` → `images: false` |
| `id` | Comment: `// source_id: ...` | No Zed equivalent; preserved as comment |
| `index` | Comment: `// source_index: ...` | No Zed equivalent; preserved as comment |

### Provider Protocol Mapping

| Source `provider` Value | Zed Provider Section | Rationale |
|---|---|---|
| `anthropic` | `language_models.anthropic` | Direct: Zed has native Anthropic support with custom `api_url` |
| `generic-chat-completion-api` | `language_models.openai_compatible` | Closest match: OpenAI-compatible chat completions API |

---

## API Key Resolution

### Mechanism

Zed stores API keys via:
- **Anthropic provider:** OS keychain (via Agent Panel settings UI) or `ANTHROPIC_API_KEY` environment variable
- **OpenAI-compatible providers:** `<PROVIDER_NAME>_API_KEY` environment variable (provider name uppercased, special chars → underscore)

Since Zed has a secrets mechanism (not inline in settings.json), API keys were injected as **Windows user-level environment variables**.

### Resolved Keys

| Source Variable | Target Env Var | Provider | Status |
|---|---|---|---|
| `ZAI_CODING_PLAN_API_KEY` | `ANTHROPIC_API_KEY` | `anthropic` | ✅ Set (49 chars) |
| `ZAI_CODING_PLAN_API_KEY` | `Z_AI_CODING_PLAN_OPENAI_API_KEY` | `openai_compatible."Z.AI Coding Plan OpenAI"` | ✅ Set (49 chars) |
| `KIMI_K25_OLLAMA_API_KEY` | `KIMI_K25_OLLAMA_API_KEY` | `openai_compatible."Kimi K25 Ollama"` | ✅ Set (57 chars) |

> **Note:** `ANTHROPIC_API_KEY` was not previously set. Setting it to the Z.AI key routes all Zed Anthropic requests through Z.AI's proxy. To use real Anthropic models, update this env var or use Zed's Agent Panel to set a different key in the OS keychain.

---

## Target Config File

- **Path:** `C:\Users\nmill\AppData\Roaming\Zed\settings.json`
- **Format:** JSONC (JSON with comments and trailing commas)
- **Section modified:** `language_models` (replaced existing `openai_compatible."Z.ai"` with new `anthropic` + `openai_compatible` sections)
- **Other settings:** All preserved (edit_predictions, context_servers, ssh_connections, agent, theme, etc.)

### Previous State

The existing `language_models` section had:
- `openai_compatible."Z.ai"` with 3 manually-configured models (GLM 4.7, GLM 5.0, GLM 4.5-Air)

### New State

The `language_models` section now has:
- `anthropic` with 6 models (Z.AI Anthropic proxy)
- `openai_compatible."Z.AI Coding Plan OpenAI"` with 1 model
- `openai_compatible."Kimi K25 Ollama"` with 1 model

---

## Issues and Notes

| Issue | Status | Resolution |
|---|---|---|
| Zed's `anthropic` provider `api_url` is provider-wide, not per-model | ⚠️ Known limitation | All Anthropic requests (including built-in models) route through Z.AI. To restore default Anthropic, remove `api_url` from the `anthropic` section. |
| Source `maxOutputTokens` used for both `max_tokens` and `max_output_tokens` | ⚠️ Best-effort | Source provides only output token limit. Used same value for context window (`max_tokens`) since actual context window sizes are not in source data. |
| Source `id` and `index` have no Zed equivalent | ✅ Resolved | Preserved as JSONC comments per model entry for lossless translation. |
| Source `noImageSupport` has no Anthropic-provider equivalent | ✅ Resolved | Preserved as provider-level comment for Anthropic; mapped to `capabilities.images` for OpenAI-compatible. |
| Previous `Z.ai` provider models replaced | ✅ Expected | Old manually-configured models superseded by source-generated entries. |
