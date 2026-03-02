# Model Providers — Source of Truth

This directory holds the **provider-centric** source of truth for all model providers
you have access to. Each provider is a YAML file describing the cloud service, its
API endpoints, and the models available through it.

## Conceptual model

```
Provider  (cloud service you have an account/plan with)
 └─ Endpoint  (a base URL + API compatibility type)
     └─ Model  (a specific model ID served at that endpoint)
```

**Sources** = the providers listed here (the actual cloud services).
**Targets** = inference clients that consume these endpoints via BYOK or OAuth proxies
(e.g. Factory Droid, Zed, OpenCode, Claude Code, VS Code Copilot Chat, Kilo Code, etc.).

## Directory layout

```
.source/model-providers/
├── providers/              # One YAML file per provider
│   ├── zai-coding-plan.yaml
│   ├── google-ai-studio.yaml
│   ├── chatgpt-codex.yaml
│   ├── openrouter.yaml
│   ├── alibaba-model-studio.yaml
│   ├── mistral.yaml
│   ├── kimi.yaml
│   ├── ovhcloud.yaml
│   └── github-copilot.yaml
├── .api_keys               # Secret API key values (gitignored, env-file format)
├── .factory.archived/      # [ARCHIVED] Old Factory CLI source — now a target, not a source
├── .zed.archived/          # [ARCHIVED] Old Zed conversion report
└── README.md               # This file
```

## Provider YAML schema

```yaml
# Comment line (free-form, ignored by parsers)
name: <Human-readable provider name>
id: <kebab-case identifier, matches filename without .yaml>
description: >-
  <Multi-line description of what this provider is and how you access it.>
website: <Provider's URL>
access_type: <subscription | free-tier | trial | api-key>
api_key_var: <ENV_VAR_NAME referencing .api_keys file>

endpoints:
  - base_url: <Full URL of the API endpoint>
    compatibility: <openai | anthropic>
    models:
      - id: <model identifier sent to the API>
        display_name: <Human-readable label>
        max_output_tokens: <number>
        image_support: <true | false>
```

### Field reference

| Field | Level | Required | Description |
|---|---|---|---|
| `name` | provider | yes | Human-readable provider name |
| `id` | provider | yes | Kebab-case ID (matches filename) |
| `description` | provider | yes | What this provider is |
| `website` | provider | no | Provider URL |
| `access_type` | provider | yes | How you access it: `subscription`, `free-tier`, `trial`, or `api-key` |
| `api_key_var` | provider | yes | Env var name in `.api_keys` holding the secret |
| `endpoints` | provider | yes | List of API endpoints |
| `base_url` | endpoint | yes | Full API base URL |
| `compatibility` | endpoint | yes | `openai` or `anthropic` |
| `models` | endpoint | yes | List of models at this endpoint |
| `id` | model | yes | Model identifier sent in API calls |
| `display_name` | model | yes | Human-readable label |
| `max_output_tokens` | model | yes | Max output token limit |
| `image_support` | model | no | Whether the model accepts image inputs (default: `false`) |

## API key handling

Secrets are stored in `.api_keys` (gitignored), one `NAME=VALUE` pair per line:

```
ZAI_CODING_PLAN_API_KEY=<actual-key>
KIMI_K25_OLLAMA_API_KEY=<actual-key>
GOOGLE_AI_STUDIO_API_KEY=<actual-key>
```

Each provider YAML references its key by variable name in `api_key_var`.
When generating targets, the generator reads `.api_keys` to resolve variable → value.

**Rules:**
- Never commit raw key values to version control.
- If the target stores config in a version-controlled location, use env var references or the target's secrets mechanism instead of inlining keys.
- Inline key values only into user-wide config files that are not version-controlled.

## Adding a new provider

1. Create `providers/<id>.yaml` following the schema above.
2. Add the API key variable to `.api_keys`.
3. Run the generator against your desired target(s).

## Relationship to targets

The generation task guide (`generate-target-model-providers.md`) reads these provider
YAML files and translates them into each target client's specific format. Factory Droid,
Zed Editor, OpenCode, and any other BYOK-capable client are all **targets**, not sources.
