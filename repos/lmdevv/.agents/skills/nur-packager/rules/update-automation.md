# Update Automation

Create auto-update scripts and GitHub Actions workflows for keeping packages current.

## Update Script Pattern

Every package with a remote source should have an update script. Place it in `scripts/update-<name>.sh` or `pkgs/<name>/update.sh`.

### Template: Binary Release Updates

```bash
#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://example.com/releases"
NIX_FILE="pkgs/my-tool/default.nix"

die() {
  echo "error: $*" >&2
  exit 1
}

# Resolve repository root
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT=$(git rev-parse --show-toplevel)
else
  SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd -P)
  REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd -P)
fi

cd "$REPO_ROOT"

[ -f "$NIX_FILE" ] || die "cannot find $NIX_FILE"

require_tools() {
  command -v curl >/dev/null || die "curl is required"
  command -v python3 >/dev/null || die "python3 is required"
  command -v nix >/dev/null || die "nix is required"
}

prefetch_sri() {
  local url="$1"
  nix --extra-experimental-features 'nix-command flakes' \
    store prefetch-file --json "$url" \
    | python3 -c 'import sys, json; d=json.load(sys.stdin); print(d.get("hash") or d["narHash"])'
}

discover_latest_version() {
  # If FORCE_VERSION is set, use that.
  if [ -n "${FORCE_VERSION:-}" ]; then
    echo "$FORCE_VERSION"
    return 0
  fi

  # Adjust this per-project's version discovery method:
  # Option A: GitHub releases API
  curl -fsSL "https://api.github.com/repos/OWNER/REPO/releases/latest" \
    | python3 -c 'import sys, json; print(json.load(sys.stdin)["tag_name"].lstrip("v"))'

  # Option B: Version file/endpoint
  # curl -fsSL "$BASE_URL/latest/VERSION" | tr -d '[:space:]'

  # Option C: npm registry
  # curl -fsSL "https://registry.npmjs.org/PACKAGE/latest" | python3 -c 'import sys, json; print(json.load(sys.stdin)["version"])'
}

current_version() {
  sed -n -E 's/^[[:space:]]*version[[:space:]]*=[[:space:]]*"([^"]+)";$/\1/p' "$NIX_FILE"
}

update_nix_file() {
  local new_version="$1"
  local h_x86_64_linux="$2"
  local h_aarch64_linux="$3"
  local h_x86_64_darwin="$4"
  local h_aarch64_darwin="$5"

  # Replace version
  sed -i -E "s#(^[[:space:]]*version[[:space:]]*=[[:space:]]*\")([^\"]+)(\";)#\\1${new_version}\\3#" "$NIX_FILE"

  # Replace per-system hashes
  sed -i -E "s#(\"x86_64-linux\"[[:space:]]*=[[:space:]]*\")[^\"]+(\";)#\\1${h_x86_64_linux}\\2#" "$NIX_FILE"
  sed -i -E "s#(\"aarch64-linux\"[[:space:]]*=[[:space:]]*\")[^\"]+(\";)#\\1${h_aarch64_linux}\\2#" "$NIX_FILE"
  sed -i -E "s#(\"x86_64-darwin\"[[:space:]]*=[[:space:]]*\")[^\"]+(\";)#\\1${h_x86_64_darwin}\\2#" "$NIX_FILE"
  sed -i -E "s#(\"aarch64-darwin\"[[:space:]]*=[[:space:]]*\")[^\"]+(\";)#\\1${h_aarch64_darwin}\\2#" "$NIX_FILE"
}

main() {
  require_tools

  local cur ver
  cur=$(current_version)
  ver=$(discover_latest_version)

  if [ -z "$ver" ]; then
    echo "warning: could not discover latest version automatically." >&2
    if [ -n "${FORCE_VERSION:-}" ]; then
      echo "using FORCE_VERSION=$FORCE_VERSION" >&2
      ver="$FORCE_VERSION"
    else
      echo "nothing to do; exiting successfully" >&2
      exit 0
    fi
  fi

  if [ "$ver" = "$cur" ]; then
    echo "my-tool is already up-to-date ($ver)."
    exit 0
  fi

  echo "Updating my-tool: $cur -> $ver"

  # Matrix of systems -> (os, arch)
  # Adjust naming to match upstream's URL pattern
  declare -A OS_BY_SYSTEM=(
    [x86_64-linux]=linux
    [aarch64-linux]=linux
    [x86_64-darwin]=darwin
    [aarch64-darwin]=darwin
  )
  declare -A ARCH_BY_SYSTEM=(
    [x86_64-linux]=x64
    [aarch64-linux]=arm64
    [x86_64-darwin]=x64
    [aarch64-darwin]=arm64
  )

  local systems=(x86_64-linux aarch64-linux x86_64-darwin aarch64-darwin)
  declare -A HASH

  for sys in "${systems[@]}"; do
    os="${OS_BY_SYSTEM[$sys]}"
    arch="${ARCH_BY_SYSTEM[$sys]}"
    url="$BASE_URL/$ver/my-tool-$os-$arch.tar.gz"
    echo "Prefetching $sys from $url ..." >&2
    HASH[$sys]=$(prefetch_sri "$url")
  done

  update_nix_file \
    "$ver" \
    "${HASH[x86_64-linux]}" \
    "${HASH[aarch64-linux]}" \
    "${HASH[x86_64-darwin]}" \
    "${HASH[aarch64-darwin]}"

  echo "Update complete."
}

main "$@"
```

### Template: Source Package Updates (Go/Rust)

For source-built packages, the update script is simpler:

```bash
#!/usr/bin/env bash
set -euo pipefail

NIX_FILE="pkgs/my-tool/default.nix"
REPO="owner/repo"

die() { echo "error: $*" >&2; exit 1; }

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"
[ -f "$NIX_FILE" ] || die "cannot find $NIX_FILE"

# Get latest version from GitHub
VERSION=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
  | python3 -c 'import sys, json; print(json.load(sys.stdin)["tag_name"].lstrip("v"))')

CURRENT=$(sed -n -E 's/^[[:space:]]*version[[:space:]]*=[[:space:]]*"([^"]+)";$/\1/p' "$NIX_FILE")

if [ "$VERSION" = "$CURRENT" ]; then
  echo "my-tool is already up-to-date ($VERSION)."
  exit 0
fi

echo "Updating my-tool: $CURRENT -> $VERSION"

# Update version
sed -i -E "s#(^[[:space:]]*version[[:space:]]*=[[:space:]]*\")([^\"]+)(\";)#\\1${VERSION}\\3#" "$NIX_FILE"

# Update source hash (set to empty, then build to get correct hash)
sed -i -E 's#(hash[[:space:]]*=[[:space:]]*")[^"]+(";)#\1\2#' "$NIX_FILE"

# Build to get the correct hash
echo "Building to fetch correct hashes..."
nix build ".#my-tool" 2>&1 || true

echo "Update complete. Check the build output for correct hashes."
```

### Template: npm Package Updates

```bash
#!/usr/bin/env bash
set -euo pipefail

NIX_FILE="pkgs/my-tool/default.nix"
PACKAGE_NAME="my-npm-tool"

die() { echo "error: $*" >&2; exit 1; }

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"
[ -f "$NIX_FILE" ] || die "cannot find $NIX_FILE"

# Get latest version from npm registry
VERSION=$(curl -fsSL "https://registry.npmjs.org/$PACKAGE_NAME/latest" \
  | python3 -c 'import sys, json; print(json.load(sys.stdin)["version"])')

CURRENT=$(sed -n -E 's/^[[:space:]]*version[[:space:]]*=[[:space:]]*"([^"]+)";$/\1/p' "$NIX_FILE")

if [ "$VERSION" = "$CURRENT" ]; then
  echo "$PACKAGE_NAME is already up-to-date ($VERSION)."
  exit 0
fi

echo "Updating $PACKAGE_NAME: $CURRENT -> $VERSION"

# Update version
sed -i -E "s#(^[[:space:]]*version[[:space:]]*=[[:space:]]*\")([^\"]+)(\";)#\\1${VERSION}\\3#" "$NIX_FILE"

# Clear npmDepsHash so Nix recalculates it
sed -i -E 's#(npmDepsHash[[:space:]]*=[[:space:]]*")[^"]+(";)#\1\2#' "$NIX_FILE"

echo "Update complete. Run 'nix build .#my-tool' to get the correct npm deps hash."
```

## GitHub Actions Workflow

Create `.github/workflows/update-<name>.yml` for automatic daily updates:

```yaml
name: update-my-tool

on:
  schedule:
    - cron: '0 6 * * *'  # Daily at 06:00 UTC
  workflow_dispatch:       # Allow manual trigger

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: cachix/install-nix-action@v30
        with:
          extra_nix_config: |
            experimental-features = nix-command flakes

      - name: Run update script
        run: |
          chmod +x scripts/update-my-tool.sh
          bash scripts/update-my-tool.sh

      - name: Check for changes
        id: check_changes
        run: |
          if git diff --quiet pkgs/my-tool/default.nix; then
            echo "changed=false" >> "$GITHUB_OUTPUT"
          else
            echo "changed=true" >> "$GITHUB_OUTPUT"
          fi

      - name: Commit and push
        if: steps.check_changes.outputs.changed == 'true'
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add pkgs/my-tool/default.nix
          git commit -m "my-tool: auto-update"
          git push
```

## Version Discovery Methods

Different projects expose versions differently. Here are common patterns:

| Source | Method | Command |
|---|---|---|
| GitHub releases (latest) | API endpoint | `curl -sL https://api.github.com/repos/OWNER/REPO/releases/latest \| jq -r '.tag_name \| ltrimstr("v")'` |
| GitHub tags | API endpoint | `curl -sL https://api.github.com/repos/OWNER/REPO/tags \| jq -r '.[0].name \| ltrimstr("v")'` |
| npm registry | Registry API | `curl -sL https://registry.npmjs.org/PACKAGE/latest \| jq -r '.version'` |
| Crates.io | Registry API | `curl -sL https://crates.io/api/v1/crates/CRATE \| jq -r '.crate.max_version'` |
| PyPI | JSON API | `curl -sL https://pypi.org/pypi/PACKAGE/json \| jq -r '.info.version'` |
| Custom VERSION file | HTTP GET | `curl -fsSL https://example.com/latest/VERSION` |
| Binary tool output | Run binary | Build current version, run `./result/bin/tool update` |
| Git repo HEAD | Git ls-remote | `git ls-remote --sort=-version:refname --tags https://github.com/OWNER/REPO \| head -1` |

## passthru.updateScript

For packages that support `nix run .#my-tool.updateScript`:

```nix
# In default.nix
stdenv.mkDerivation {
  # ... package definition ...

  passthru = {
    sources = sources;  # or sha256BySystem
    updateScript = ./update.sh;
  };
}
```

This allows `nix run .#my-tool.updateScript` to execute the update script directly.