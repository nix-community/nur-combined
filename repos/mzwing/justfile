# alejandra's --exclude matches literal paths only, no globs, and the generated files below need one — so the nix list comes from git, which also keeps .devenv out for free.
# nvfetcher's _sources/generated.nix and crate2nix's pkgs/*/Cargo.nix are generated and do not follow the alejandra style.
nix_sources := "git ls-files '*.nix' ':!:_sources/generated.nix' ':!:pkgs/*/Cargo.nix'"

# Only the CI scripts. pkgs/*/update-pins.sh and scripts/package-updates/lib/pin-utils.sh are writeShellApplication bodies: Nix already shellchecks them at build time with the right shell and excludeShellChecks, and shfmt must never touch them — it rewrites associative-array subscripts as arithmetic, turning ${asset_url[x86_64-unknown-linux-gnu]} into a subtraction.
shell_sources := "git ls-files 'scripts/ci/*.sh'"
python_sources := "git ls-files '*.py'"

default: lint

# Every check CI runs, minus `nix flake check` — that one needs a warm store.
lint: lint-nix lint-nix-types lint-actions lint-shell lint-python

# Rewrite every file in place.
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

# No ty: modules/*/merge.py import runtime dependencies (tomli_w) that only exist inside the Nix build, so type checking them needs those packages added to devenv first.
lint-python:
    {{ python_sources }} | xargs ruff format --check
    {{ python_sources }} | xargs ruff check
