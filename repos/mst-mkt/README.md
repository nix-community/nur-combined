# mst-mkt/nur-packages

mst-mkt's Nix user repository.

## Usage

```nix
{
  inputs.nur-packages = {
    url = "github:mst-mkt/nur-packages";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

- Packages are exposed as `packages.<system>.<name>` and via `overlays.default`.
- Home Manager modules are exposed as `homeModules.<name>`.
- Build artifacts are pushed to the `mst-mkt` cachix cache.

## Packages

| Name                                                     | Description                                                                      | License         | Platforms                                   |
| -------------------------------------------------------- | -------------------------------------------------------------------------------- | --------------- | ------------------------------------------- |
| [calldiff](https://github.com/tanishqkancharla/calldiff) | Diffs of function call stacks across git commits, built on Tree-sitter           | MIT             | x86_64-linux, aarch64-linux, aarch64-darwin |
| [esa-cli](https://github.com/esaio/esa-cli)              | Official CLI for esa.io                                                          | MIT             | x86_64-linux, aarch64-linux, aarch64-darwin |
| [gengo](https://github.com/spenserblack/gengo)           | Linguist-inspired language classifier with multiple file source handlers         | MIT, Apache-2.0 | x86_64-linux, aarch64-linux, aarch64-darwin |
| [gh-pr-reviews](https://github.com/k1LoW/gh-pr-reviews)  | GitHub CLI extension to identify unresolved review comments in a pull request    | MIT             | x86_64-linux, aarch64-linux, aarch64-darwin |
| [git-hunk](https://github.com/nexxeln/git-hunk)          | Non-interactive hunk staging for AI agents                                       | Apache-2.0      | x86_64-linux, aarch64-linux, aarch64-darwin |
| [omniwm](https://github.com/BarutSRB/OmniWM)             | macOS tiling window manager inspired by Niri and Hyprland                        | GPL-2.0-only    | aarch64-darwin                              |
| [rinkaku](https://github.com/hiro-o918/rinkaku)          | Condense PR diffs into signatures and their dependencies for LLM-friendly review | MIT             | x86_64-linux, aarch64-linux, aarch64-darwin |
