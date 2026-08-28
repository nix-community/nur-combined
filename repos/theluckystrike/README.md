# nur-packages

[![Build and populate cache](https://github.com/theluckystrike/nur-packages/actions/workflows/build.yml/badge.svg)](https://github.com/theluckystrike/nur-packages/actions/workflows/build.yml)

Personal [NUR](https://github.com/nix-community/NUR) repository — Nix packages
that are not (yet) in nixpkgs.

## Packages

| Attribute | Description |
|---|---|
| `bln-mcp-server` | Model Context Protocol stdio server exposing grammar, style, translation and tone tools to MCP clients (Claude Desktop, Claude Code, Cursor). `check_grammar` and `improve_writing` run fully offline against a local 70-rule engine; no API key and no network access at run time. |

## Usage

```nix
{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.nur.repos.theluckystrike.bln-mcp-server
  ];
}
```

Then point an MCP client at the resulting binary:

```json
{
  "mcpServers": {
    "belikenative": { "command": "bln-mcp-server" }
  }
}
```

## License

The packaging expressions in this repository are MIT licensed (see `LICENSE`).
Packaged software keeps its own license, declared in each package's `meta`.
