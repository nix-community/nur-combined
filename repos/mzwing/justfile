# Format tracked Nix sources except generated files.
nix_sources := "git ls-files '*.nix' ':!:_sources/generated.nix' ':!:pkgs/*/Cargo.nix'"

# Format standalone CI scripts only; shfmt breaks updater array subscripts embedded in Nix.
shell_sources := "git ls-files 'scripts/ci/*.sh'"
python_sources := "git ls-files '*.py'"

default: lint

# CI lint checks; flake evaluation needs a warm store.
lint: lint-nix lint-nix-types lint-actions lint-shell lint-python

# Format in place.
fmt:
    {{ nix_sources }} | xargs alejandra
    {{ shell_sources }} | xargs shfmt --write
    {{ python_sources }} | xargs ruff format
    {{ python_sources }} | xargs ruff check --fix

lint-nix:
    {{ nix_sources }} | xargs alejandra --check

lint-nix-types:
    typenix --noEmit

lint-actions:
    actionlint

lint-shell:
    {{ shell_sources }} | xargs shfmt --diff
    {{ shell_sources }} | xargs shellcheck

# Runtime-only Python dependencies prevent local type checking.
lint-python:
    {{ python_sources }} | xargs ruff format --check
    {{ python_sources }} | xargs ruff check
