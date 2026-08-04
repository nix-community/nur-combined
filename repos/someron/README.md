# nur
My personal NUR packages.
## How to use
### NUR
You have to [include the NUR](https://github.com/nix-community/NUR?tab=readme-ov-file#installation) in your configuration.

My NUR namespace is `nur.repos.someron`.

### flake
You can also include this repository as a standalone flake:
```Nix
inputs.someron-nur = {
    url = "git+https://codeberg.org/someron/nur.git";
    inputs.nixpkgs.follows = "nixpkgs";
};
```

## Packages
### External
#### riscVivid
- Source: https://github.com/unia-sik/riscVivid
- Description: A RISC-V processor simulator
- Current Version: 1.4 *(2022-07-12)*
- License: GPL 3.0 (or later)
- Attribute: `nur.repos.someron.pkgs.riscVivid`

#### filebrowser-quantum
- Source: https://github.com/gtsteffaniak/filebrowser
- Description: 📂 Web File Browser
- Current Version: v1.3.3-stable *(2026-05-19)*
- License: Apache License 2.0
- Attribute: `nur.repos.someron.pkgs.filebrowser-quantum`

#### upsnap
- Source: https://github.com/seriousm4x/UpSnap
- Description: A simple wake on lan web app written with SvelteKit, Go and PocketBase.
- Current Version: 5.3.5 *(2026-05-14)*
- License: MIT
- Attribute: `nur.repos.someron.pkgs.upsnap`

### pathspec
- Source: https://github.com/cpburnz/python-pathspec
- Description: Utility library for gitignore style pattern matching of file paths.
- Current Version: v1.1.1 *(2026-04-27)*
- License: MIT (since 2025-04-25); Mozilla Public License 2.0
- Attribute: `nur.repos.someron.pkgs.pathspec`

### bms25s
- Source: https://github.com/xhluca/bm25s
- Description: Fast BM25 search in Python, powered by Numpy and Numba 
- Current Version: 0.3.9 *(2026-05-14)*
- License: MIT
- Attribute: `nur.repos.someron.pkgs.bm25s`

### tree-sitter-language-pack
The build for this package is really hacky. Use the version included in nixpkgs.

- Source: https://github.com/xhluca/bm25s
- Description: Comprehensive tree-sitter grammar compilation with polyglot bindings — Rust, Python, Node.js, Go, Java, Ruby, Elixir, PHP, C#, WASM, Dart, Kotlin-Android, Swift, Zig, and CLI. 305+ languages.
- Current Version: 1.6.2 *(2026-04-18)*
- License: MIT
- Attribute: `nur.repos.someron.pkgs.tree-sitter-language-pack`

### semble
- Source: https://github.com/MinishLab/semble
- Description: Fast and Accurate Code Search for Agents. Uses ~98% fewer tokens than grep+read 
- Current Version: v0.2.0 *(2026-05-21)*
- License: MIT
- Attribute: `nur.repos.someron.pkgs.semble`

### model2vec
- Source: https://github.com/MinishLab/model2vec
- Description: Fast State-of-the-Art Static Embeddings 
- Current Version: v0.8.1 *(2026-03-27)*
- License: MIT
- Attribute: `nur.repos.someron.pkgs.model2vec`

### vicinity
- Source: https://github.com/MinishLab/vicinity
- Description: Lightweight Nearest Neighbors with Flexible Backends 
- Current Version: v0.4.4 *(2026-04-14)*
- License: MIT
- Attribute: `nur.repos.someron.pkgs.vicinity`

### Own packages
#### systemd-sops-creds
- Source: https://codeberg.org/someron/systemd-sops-creds
- Description: Use your SOPS files as systemd credentials.
- Current Version: v1.0.0 *(2026-01-28)*
- License: MIT
- Attribute: `nur.repos.someron.pkgs.systemd-sops-creds`

#### beszel-provisioner
- Source: https://codeberg.org/someron/beszel-provisioner
- Description: Declaratively configure users, systems, alerts and OAuth2 for beszel!
- Current Version: 2025-09-29
- License: MIT
- Attribute: `nur.repos.someron.pkgs.beszel-provisioner`

#### simple-llm-router
- Source: https://codeberg.org/someron/simple-llm-router
- Description: A simple LLM-proxy that uses OpenRouter-Style model ids to address models from multiple providers.
- Current Version: v1.0.1 *(2026-06-26)*
- License: MIT
- Attribute: `nur.repos.someron.pkgs.simple-llm-router`

#### carddav-immich-bday-sync
- Source: [in this repo](pkgs/carddav-immich-bday-sync/src/)
- Description: Sync the birthdays of your contacts on a CardDAV server to your Immich instance.
- License: MIT
- Attribute: `nur.repos.someron.pkgs.carddav-immich-bday-sync`
