# Templates for development

Most of them just use a simple direnv with the `use flakes` directive and its corresponding flake, while Rust still rely on [devenv](devenv.sh).

All of the environments contain the corresponding characteristics:
- Contains configurations for `dprint` and `helix`
- Contains a Makefile for common commands
- Contains the following packages as basic dependencies:
  - dprint
  - gnumake
  - marksman
  - nil
  - vscode-langservers-extracted (JSON)
  - yaml-language-server
