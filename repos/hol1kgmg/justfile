# nur-packages — common commands
#
# Run `just` to see this list.

set shell := ["bash", "-euo", "pipefail", "-c"]

# Show available recipes
default:
    @just --list

# --- inspect -----------------------------------------------------------------

# List the packages exposed by the flake for this system
list:
    #!/usr/bin/env bash
    set -euo pipefail
    system=$(nix eval --impure --raw --expr 'builtins.currentSystem')
    nix eval --json ".#packages.${system}" --apply builtins.attrNames \
      | tr -d '[]"' | tr ',' '\n'

# Evaluate a package without building it: just eval herdr
eval PKG:
    nix eval --raw .#{{PKG}}.drvPath

# Show the flake outputs tree
show:
    nix flake show

# --- build / run -------------------------------------------------------------

# Build one package: just build herdr [extra nix args...]
build PKG *ARGS:
    nix build .#{{PKG}} -L {{ARGS}}

# Build every package for this system: just build-all [extra nix args...]
build-all *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    system=$(nix eval --impure --raw --expr 'builtins.currentSystem')
    pkgs=$(nix eval --json ".#packages.${system}" --apply builtins.attrNames \
      | tr -d '[]"' | tr ',' ' ')
    for p in $pkgs; do
      echo "==> building $p"
      nix build ".#$p" -L {{ARGS}}
    done

# Run a package's main program: just run herdr -- --version
run PKG *ARGS:
    nix run .#{{PKG}} {{ARGS}}

# Drop into a shell with a package on PATH: just shell herdr
shell PKG *ARGS:
    nix shell .#{{PKG}} {{ARGS}}

# Reproduce the GitHub Actions build (uses <nixpkgs>, not the flake lock)
ci:
    nix-build ci.nix -A buildOutputs

# Check the flake (evaluates all outputs)
check *ARGS:
    nix flake check {{ARGS}}

# --- maintenance -------------------------------------------------------------

# Update flake inputs: just update  /  just update nixpkgs
update *INPUTS:
    nix flake update {{INPUTS}}

# Format nix files with nixfmt: just fmt [paths...]
fmt *PATHS='.':
    nix run nixpkgs#nixfmt -- {{PATHS}}

# Remove build result symlinks
clean:
    rm -rf result result-*

# --- packaging helpers -------------------------------------------------------

# List an upstream repo's newest tags: just tags ogulcancelik herdr
tags OWNER REPO:
    #!/usr/bin/env bash
    set -euo pipefail
    git ls-remote --tags --refs "https://github.com/{{OWNER}}/{{REPO}}" \
      | awk '{print $2}' | sed 's|refs/tags/||' | sort -V | tail -20

# Get the SRI hash of a GitHub tarball: just prefetch ogulcancelik herdr v0.9.0
prefetch OWNER REPO REV:
    #!/usr/bin/env bash
    set -euo pipefail
    raw=$(nix-prefetch-url --unpack --type sha256 \
      "https://github.com/{{OWNER}}/{{REPO}}/archive/{{REV}}.tar.gz" 2>/dev/null | tail -1)
    nix hash convert --hash-algo sha256 --to sri "$raw"

# Bump a package's version, rev and hash: just bump herdr 0.9.0
bump PKG VERSION:
    #!/usr/bin/env bash
    set -euo pipefail
    f="pkgs/{{PKG}}/default.nix"
    [[ -f "$f" ]] || { echo "no such package file: $f" >&2; exit 1; }

    owner=$(grep -m1 -E '^\s*owner = ' "$f" | sed -E 's/.*"(.*)".*/\1/')
    repo=$(grep -m1 -E '^\s*repo = ' "$f" | sed -E 's/.*"(.*)".*/\1/')
    old_version=$(grep -m1 -E '^\s*version = "' "$f" | sed -E 's/.*"(.*)".*/\1/')
    rev_expr=$(grep -m1 -E '^\s*rev = ' "$f" | sed -E 's/.*rev = (.*);.*/\1/')
    old_hash=$(grep -m1 -E '^\s*hash = ' "$f" | sed -E 's/.*"(.*)".*/\1/')

    if [[ -z "$owner" || -z "$repo" ]]; then
      echo "could not find fetchFromGitHub owner/repo in $f — bump it by hand" >&2
      exit 1
    fi
    if [[ -z "$old_version" ]]; then
      echo "could not find a 'version = \"...\"' line in $f — bump it by hand" >&2
      exit 1
    fi

    # Work out the new rev from how the old one was written:
    #   "v${version}" -> follows version automatically
    #   "v0.8.2" / "0.1.7" -> literal, keep any prefix before the version
    old_rev_literal=""
    if [[ "$rev_expr" == *'${version}'* ]]; then
      prefix=$(sed -E 's/.*"(.*)\$\{version\}.*/\1/' <<<"$rev_expr")
      new_rev="${prefix}{{VERSION}}"
    else
      old_rev_literal=$(sed -E 's/.*"(.*)".*/\1/' <<<"$rev_expr")
      prefix="${old_rev_literal%$old_version}"
      if [[ "$prefix" == "$old_rev_literal" ]]; then
        echo "rev ($old_rev_literal) does not contain version ($old_version) — bump it by hand" >&2
        exit 1
      fi
      new_rev="${prefix}{{VERSION}}"
    fi

    echo "==> $repo: $old_version -> {{VERSION}} (rev $new_rev)"
    raw=$(nix-prefetch-url --unpack --type sha256 \
      "https://github.com/${owner}/${repo}/archive/${new_rev}.tar.gz" 2>/dev/null | tail -1)
    new_hash=$(nix hash convert --hash-algo sha256 --to sri "$raw")
    echo "==> hash $new_hash"

    sed -i.bak -e "s|version = \"${old_version}\"|version = \"{{VERSION}}\"|" "$f"
    if [[ -n "$old_rev_literal" ]]; then
      sed -i.bak -e "s|rev = \"${old_rev_literal}\"|rev = \"${new_rev}\"|" "$f"
    fi
    sed -i.bak -e "s|${old_hash}|${new_hash}|" "$f"
    rm -f "$f.bak"

    if grep -q 'cargoHash' "$f"; then
      echo "!! $f pins a cargoHash — it is now stale."
      echo "   Run 'just build {{PKG}}' and copy the 'got:' hash from the failure."
    fi
    git --no-pager diff -- "$f" || true
