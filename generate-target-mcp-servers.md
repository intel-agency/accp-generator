# Generate Target Client MCP Servers

Use the source MCP server configurations and translate them from the source format into the target's specific format, then add them to the target's MCP server configuration location.

## Goal

Your goal is to create corresponding MCP server configuration entries in the target's format and place them at the target's user-wide MCP configuration location in the **same environment as the source**. First detect whether the source is being run from **Windows** or **Linux/WSL**, record that as the target environment, and then use the target's user-wide location for that same environment. Use the web fetch tools to discover the target docs and recursively follow any documentation links you find along the way, executing non-interactively without user intervention.

## Source MCP server files

Location: <./.source/mcp-servers/Code - Insiders/>
Format: VS Code Insiders MCP configuration JSON (`mcp.json` with a `servers` object)

### Source format reference

The source is a VS Code Insiders `mcp.json` file. MCP servers are defined in the `servers` object. Each entry is keyed by a server name and has the following fields:

| Field | Type | Required | Description |
|---|---|---|---|
| `type` | string | yes | Transport type (`stdio` or `http`). |
| `command` | string | stdio only | Executable command to launch the server (e.g., `npx`, `node`, `python`). |
| `args` | string[] | stdio only | Command-line arguments passed to the command. |
| `url` | string | http only | HTTP endpoint URL for the MCP server. |
| `gallery` | string | no | Gallery/registry URL for the server (metadata only). |
| `version` | string | no | Pinned version of the MCP server package. |
| `disabled` | boolean | no | Whether the server is disabled (default: `false`). |

### Source MCP servers inventory

The following MCP servers are defined in the source file:

| # | Server Name | Type | Command / URL | Package / Endpoint | Version | Disabled |
|---|---|---|---|---|---|---|
| 1 | sequential-thinking | `stdio` | `npx` | `@modelcontextprotocol/server-sequential-thinking` | `0.0.1` | no |
| 2 | memory | `stdio` | `npx` | `@modelcontextprotocol/server-memory` | `0.0.1` | no |
| 3 | chrome-devtools | `stdio` | `npx` | `chrome-devtools-mcp@latest` | — | yes |
| 4 | desktop-commander | `stdio` | `npx` | `@wonderwhy-er/desktop-commander@latest` | — | yes |
| 5 | github-mcp-server | `http` | — | `https://api.githubcopilot.com/mcp/` | `0.13.0` | yes |

### Environment variable and secrets handling

Some MCP servers may require API keys or tokens passed via environment variables. If the source config includes an `env` field (object of `NAME: VALUE` pairs), handle secrets the same way as model providers:

1. If a value looks like a secret/token, replace it with a placeholder variable name in the source config.
2. Store the actual value in an `.api_keys` file at `.source/mcp-servers/Code - Insiders/.api_keys`.
3. When generating target configs, resolve placeholders from the `.api_keys` file.
4. **Never** write raw secrets into version-controlled files.

Currently, no servers in the source require API keys directly (the GitHub MCP server uses Copilot's built-in auth). If future servers require keys, follow this pattern.

## Target MCP server location and format

Given the target (name/version or vendor docs URL), automatically search the web for the target's documentation site **without asking the user for URLs**. Use the web fetch tools to locate and read the documentation, then search for the section on MCP server configuration, MCP integration, or tool server setup. In that section you need to find:

0. **Environment-specific locations:** determine and record the target's user-wide MCP config location for **Windows** and for **Linux/WSL** when both are documented.
1. **Location:** the user-wide config file path and the specific key/section within it where MCP servers are defined (NOT local workspace directory unless it is the only option)
2. **File format:** JSON, YAML, TOML, or other config format
3. **Valid fields** for each MCP server entry (server name, transport type, command, args, URL, env vars, disabled state, etc.)
4. **Transport types** supported (`stdio`, `http`, `sse`, `streamable-http`, etc.)
5. **Environment variable mechanism:** how the target expects environment variables or secrets to be passed to MCP servers (inline in config, env file reference, credential store, etc.)

After reading all of this information (gathered non-interactively via web fetch tools):

1. Create a field mapping from each source field to the most appropriate target field.
2. Document the mapping, including how each source field translates and how unmapped fields are preserved (e.g., as comments or extra metadata) to ensure a lossless translation.
3. Document the target's transport type support and how source transport types map (e.g., `stdio` -> `stdio`, `http` -> `sse` or `streamable-http` etc.).
4. Document how disabled servers should be handled (omit, comment out, or use a `disabled` flag if supported).

## Generate Target MCP Server Configurations

For each MCP server entry in the source `servers` object, generate a corresponding entry in the target's format using the field mapping from the previous section.

**IMPORTANT** The translation must be lossless—do not leave out any info from the source entry. Every source field must map to a target field (or be preserved as a comment/metadata annotation).

**NOTE:** If the target does not support the same or equivalent field, then carry it over as a comment or metadata field in the target config to preserve the information, if it cannot be used directly by the target. It's more important to have a correctly-formatted config file that it is to carry over and preserve info that the target format does not use. If it cannot be preserved without violating the target format then it must be omitted, but this should be a last resort.

**CRITICAL — Backup and safe-write procedure:**

1. **Backup first.** Before making any changes, copy the target file to a timestamped backup (e.g., `settings.json.bak.20260301T1423`). Never modify the original without a backup in place.
2. **Double-buffer edits.** Copy the target file to a temporary working file (e.g., `settings.json.tmp` in the same directory). Apply all changes to the temp copy. Only after the temp copy is verified correct, atomically replace the original with the temp copy (e.g., `Move-Item -Force` on Windows). This prevents a half-written or corrupt file if the process is interrupted.
3. **Verify after swap.** After the swap, read back the target file and confirm it parses correctly. If verification fails, restore from the backup immediately.

**Steps:**

1. Read the source `mcp.json` and parse the `servers` object.
2. If an `.api_keys` file exists at `.source/mcp-servers/Code - Insiders/.api_keys`, load the `NAME=VALUE` pairs into memory.
3. For each server entry:
   a. Map all source fields to target fields using the field mapping.
   b. Map the transport type (`stdio` or `http`) to the target's equivalent transport type.
   c. For `stdio` servers: map `command` and `args` to the target's command execution fields.
   d. For `http` servers: map `url` to the target's HTTP/SSE endpoint field.
   e. If the server has `disabled: true`, use the target's mechanism for disabling (flag, comment, or omission—document the choice).
   f. Preserve `version` and `gallery` metadata as comments or metadata fields if the target has no direct equivalent.
   g. If environment variables are present, resolve any placeholder values from `.api_keys` and insert using the target's env var mechanism.
4. Write the generated config to the target's **user-wide** location in the **same environment as the source** (Windows source -> Windows target location, Linux/WSL source -> Linux/WSL target location), not the local workspace directory.
5. If the target config file already exists, **merge** the new MCP server entries into the existing file without overwriting other settings. Read the existing file first, add/update only the MCP server entries, and write back. 
  a. If the target config file exsists and already contains a full MCP Server entry with the same name, and fields, then it must be ommitted from the generated config to avoid duplication. If it contains an entry with the same name but different fields, then the existing entry should be preserved and the new entry should be renamed (e.g., append `-1` to the server name) to avoid overwriting the existing entry, while still adding the new server configuration.

If validation or checks are required, ask the user before running any commands.

Use Windows-first (PowerShell) guidance when providing any shell instructions.

## Learned target type index

Maintain an index of learned target types in this section. Add a new subsection per target type as you learn its user-wide location, file format, and valid fields. Append new subsections in chronological order so the most recently learned target types are last. Include the URL of the target type's documentation where the information was found in each index entry.

Record the **environment** for each learned entry (`Windows` or `Linux/WSL`). If paths differ by environment, create separate entries for the same target type (for example, one Windows entry and one Linux/WSL entry) rather than collapsing them into a single path.

## Conclusion

After each run, generate a markdown report detailing the conversion process. Include:

- A list of generated/modified MCP server entries
- The target config file location used
- The field mapping applied (including transport type mapping)
- How disabled servers were handled
- How metadata fields (version, gallery) were preserved
- Any issues encountered and whether they were resolved or still persist
