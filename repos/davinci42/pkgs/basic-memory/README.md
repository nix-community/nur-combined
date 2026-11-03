# Basic Memory

`nur.repos.davinci42.basic-memory` provides `basic-memory` and `bm` for local
Markdown memory over MCP. No service or runtime package installer is configured.

## MCP

Run `${package}/bin/basic-memory` with `mcp --project main --transport stdio`:

| Environment variable | Value |
| --- | --- |
| `BASIC_MEMORY_HOME` | Absolute writable notes path |
| `BASIC_MEMORY_PROJECTS` | `{"main":{"path":"/absolute/path/to/notes"}}` |
| `BASIC_MEMORY_DEFAULT_PROJECT` | `main` |
| `BASIC_MEMORY_CONFIG_DIR` | Writable state path outside the notes repository |
| `BASIC_MEMORY_FORCE_LOCAL` | `true` |
| `BASIC_MEMORY_AUTO_UPDATE` | `false` |
| `BASIC_MEMORY_NO_PROMOS` | `1` |
| `BASIC_MEMORY_DEFAULT_SEARCH_TYPE` | `text` for full-text search by default |
| `BASIC_MEMORY_ENSURE_FRONTMATTER_ON_SYNC` | `false` to preserve existing Markdown |
| `HF_HUB_OFFLINE` | `1` to prevent Hugging Face model downloads |

Activate mutable notes links before starting MCP. Full-text search needs no API
key. Writes are asynchronous: confirm file contents before committing to Git.
Upstream removed `BASIC_MEMORY_SEMANTIC_SEARCH_ENABLED`: set
`BASIC_MEMORY_DEFAULT_SEARCH_TYPE=text` and `HF_HUB_OFFLINE=1`, or omit
`sqlite-vec` and embedding providers to keep search keyword-only without model
downloads.

## Maintenance

```sh
nix-shell --run 'just update basic-memory'
nix-shell --run 'just check basic-memory'
```

The existing daily updater runs `update.py`, refreshing the package and seven
private dependencies from the hash-verified source's `uv.lock`. Their portable
wheels are pinned in `dependencies.json`; other dependencies use nixpkgs.
FastAPI must follow the upstream pin because the read cache imports private APIs;
`fastapi-redis-sdk` is required even without a Redis service. Review
`dependencies.nix` against upstream requirements when updating; no global Python
overlay is changed.

Neither builds nor this updater require GitHub login. Release discovery needs
network access outside the sandbox and is subject to anonymous API rate limits.

Checks cover imports, CLI version, MCP discovery, read/write/search/edit, and
restart persistence using temporary data. Semantic search, PostgreSQL, cloud
integrations, and upstream test suites are not exercised.

## Temporary security exception

Nixpkgs blocks builds because the required `pybars3` 0.9.7 dependency has
CVE-2026-119716 (code injection via bracketed path segments). CI temporarily
accepts only `python3.14-pybars3-0.9.7` through a temporary `NIXPKGS_CONFIG`.
This exception applies only to CI and is not included in the exported package.

Consumers must explicitly accept the risk in the nixpkgs instance used to build
this package. For NixOS or nix-darwin configurations using their system `pkgs`:

```nix
nixpkgs.config.permittedInsecurePackages = [
  "python3.14-pybars3-0.9.7"
];
```

For a separately imported nixpkgs instance, pass the exception at import time
and use that instance when importing this repository:

```nix
let
  pkgs = import <nixpkgs> {
    config.permittedInsecurePackages = [ "python3.14-pybars3-0.9.7" ];
  };
  nurPackages = import /path/to/nur-packages { inherit pkgs; };
in
nurPackages.basic-memory
```

Match the exact dependency name reported by Nix; a Python version change can
require updating the allowlist. This bypasses the evaluation block, not the
vulnerability. Do not compile untrusted Handlebars templates. Remove both CI and
consumer exceptions once a reviewed security fix is available.

A search of Basic Memory's public issues and pull requests found no report
specifically mentioning this CVE or `pybars3` as of 2026-11-04.
[Issue #1731](https://github.com/basicmachines-co/basic-memory/issues/1731)
mentions the `pybars` import chain during MCP startup, but concerns performance,
not this vulnerability.
