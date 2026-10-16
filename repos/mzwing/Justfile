# Format tracked Nix sources except generated files.
nix_sources := "git ls-files '*.nix' ':!:pkgs/*/source.nix' ':!:pkgs/typenix/tree-sitter-nix.nix' ':!:pkgs/*/Cargo.nix'"

ts_sources := "git ls-files '*.ts'"
shell_sources := "git ls-files '*.sh'"
python_sources := "git ls-files '*.py'"

default: lint

# CI lint checks; flake evaluation needs a warm store.
lint: lint-nix lint-nix-types lint-ts lint-actions lint-shell lint-python

# Format in place.
fmt:
    {{ nix_sources }} | xargs alejandra
    {{ ts_sources }} | xargs deno fmt
    {{ shell_sources }} | xargs shfmt --write
    {{ python_sources }} | xargs ruff format
    {{ python_sources }} | xargs ruff check --fix

lint-nix:
    {{ nix_sources }} | xargs alejandra --check

lint-nix-types:
    typenix --noEmit

lint-ts:
    {{ ts_sources }} | xargs deno fmt --check
    {{ ts_sources }} | xargs deno lint
    {{ ts_sources }} | xargs deno check

lint-actions:
    actionlint

lint-shell:
    {{ shell_sources }} | xargs shfmt --diff
    {{ shell_sources }} | xargs shellcheck

# Runtime-only Python dependencies prevent local type checking.
lint-python:
    {{ python_sources }} | xargs ruff format --check
    {{ python_sources }} | xargs ruff check
