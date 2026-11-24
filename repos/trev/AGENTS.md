# AGENTS.md

## Task Completion Requirements

- `nix fmt` must be used for formatting.
- `nix flake check` must pass before considering tasks completed. Intent-to-add (`git add -N`) new files so `nix flake check` can see them.

## Package Requirements

- Packages that also exist in nixpkgs, but are maintained here to track newer upstream releases, must use a `-latest` suffix (e.g. `uv-build-latest`, `aioquic-latest`) so the packages overlay doesn't replace the nixpkgs versions that other packages depend on. The `trev` overlay also adds them without the suffix (e.g. `pkgs.trev.go` for `go-latest`), so don't add unsuffixed aliases by hand.

## Version Control Requirements

- Commit messages created by agents must follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).
- Commits created by agents must include an `Assisted-by: [tool name] ([primary model name and version])` Git commit trailer.
- Branch names created by agents must follow [Conventional Branch 1.1.0](https://conventionalbranch.org/).
