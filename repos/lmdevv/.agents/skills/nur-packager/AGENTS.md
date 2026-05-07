# NUR Packager Guide

Complete guide for packaging projects into Nix User Repository (NUR) derivations.

## Table of Contents

- [Overview](#overview)
- [Analyzing a Project](#analyzing-a-project)
- [Node.js/npm Packaging](#nodejsnpm-packaging)
- [Binary Release Packaging](#binary-release-packaging)
- [GitHub Source Builds](#github-source-builds)
- [Creating and Registering Derivations](#creating-and-registering-derivations)
- [Testing Builds](#testing-builds)
- [Update Automation](#update-automation)

---

## Overview

This guide covers the end-to-end workflow for packaging projects into NUR derivations:

1. **Analyze** the input (URL, package name, GitHub repo) to determine packaging strategy
2. **Select** the appropriate pattern (binary release, npm build, source build, etc.)
3. **Create** the derivation under `pkgs/<name>/default.nix`
4. **Register** the package in the root `default.nix`
5. **Test** the build and verify it works
6. **Automate** updates with scripts and GitHub Actions

### Strategy Decision Matrix

| Project Type | Strategy | Priority |
|---|---|---|
| CLI tool with binary releases | Multi-platform binary package | 1 (best) |
| npm CLI tool with binary releases | Binary package (prefer over npm build) | 2 |
| npm CLI tool, no binaries | `buildNpmPackage` | 3 |
| Go project source | `buildGoModule` | 4 |
| Rust project source | `buildRustPackage` | 5 |
| Python project | `buildPythonApplication` | 6 |
| Complex npm project (monorepo) | `buildNpmPackage` with overrides | 7 |
| Desktop app (AppImage/DMG) | `appimageTools` / `undmg` | 8 |

---

## Analyzing a Project

Before writing any Nix code, analyze the input to determine what kind of project it is and how it should be packaged.

### Input Types

The agent receives one of:
- A **GitHub URL** (e.g., `https://github.com/owner/repo`)
- A **npm package name** (e.g., `typescript`, `prettier`)
- A **direct download URL** (e.g., a binary or archive)
- A **project name** to search for

### Analysis Decision Tree

```
GitHub URL?
├── Check for release binaries on /releases page
├── Check package.json → Node.js project
│   ├── Has "bin" field → CLI tool (buildNpmPackage)
│   ├── Is a library → node2nix or buildNpmPackage
│   └── Uses native addons → needs nativeBuildInputs
├── Check for Cargo.toml → Rust project
├── Check for go.mod → Go project
├── Check for setup.py / pyproject.toml → Python project
└── Check for Makefile / CMakeLists.txt → C/C++ project

npm package name?
├── Check npm registry: https://registry.npmjs.org/<name>
├── Find GitHub repo from repository field
├── Check if binary releases exist (prefer those for CLI tools)
└── Falls back to buildNpmPackage from source

Direct download URL?
├── Single binary → fetchurl + installPhase
├── .deb package → dpkg + autoPatchelfHook
├── .rpm package → rpm2cpio + autoPatchelfHook
├── .tar.gz archive → autoPatchelfHook
├── .zip archive → unzip + autoPatchelfHook
└── AppImage → appimageTools.wrapType2

Curl script?
├── Extract the actual download URL(s)
├── Determine if it's platform-specific
├── Find per-platform binary URLs
└── Package as multi-platform binary release
```

### Always Check for Binary Releases First

Prefer pre-built binaries over source builds when possible. They are:
- Faster to build (no compilation step)
- More reliable (tested by upstream)
- Simpler to maintain

Check these locations:
1. GitHub Releases: `https://github.com/owner/repo/releases`
2. npm `preinstall`/`postinstall` scripts that download binaries
3. Project website/download page

### Determine Platform Matrix

For binary releases, identify which platforms are supported:

```
Common platform matrix:
├── x86_64-linux   (most common)
├── aarch64-linux  (ARM Linux)
├── x86_64-darwin  (Intel macOS)
└── aarch64-darwin  (Apple Silicon macOS)
```

URL naming patterns:
- `*-linux-amd64*`, `*-linux-x64*`, `*-x86_64-linux*` → x86_64-linux
- `*-linux-arm64*`, `*-aarch64-linux*` → aarch64-linux
- `*-darwin-amd64*`, `*-macos-x64*`, `*-x86_64-macos*` → x86_64-darwin
- `*-darwin-arm64*`, `*-macos-arm64*`, `*-aarch64-macos*` → aarch64-darwin

### Package Naming

Choose a Nix-friendly package name:
- Use lowercase
- Replace spaces and special chars with hyphens
- Keep it short and recognizable
- Must be a valid Nix identifier (letters, digits, hyphens between letters)

### Check for Existing Nix Packages

```bash
nix search nixpkgs <name>
```

### Example: Analyzing a GitHub Repo

```bash
# 1. Fetch repo info
curl -sL https://api.github.com/repos/OWNER/REPO | jq '{name, description, homepage, license: .license.spdx_id}'

# 2. Check for releases with binary assets
curl -sL https://api.github.com/repos/OWNER/REPO/releases/latest | jq '.assets[] | {name: .name, url: .browser_download_url}'

# 3. Check package.json for Node.js projects
curl -sL https://raw.githubusercontent.com/OWNER/REPO/main/package.json | jq '{name, version, bin, scripts, dependencies: (.dependencies | keys)}'

# 4. Try to find latest version tag
curl -sL https://api.github.com/repos/OWNER/REPO/tags | jq '.[0].name'
```

---

## Node.js/npm Packaging

Package Node.js projects as Nix derivations using `buildNpmPackage` or `node2nix`.

### Strategy Selection

```
Is it a CLI tool with pre-built binaries on GitHub Releases?
├── YES → Use binary-release pattern (prefer binaries over npm build)
└── NO → buildNpmPackage (recommended for most cases)
```

### buildNpmPackage (Recommended)

```nix
{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "my-tool";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "example";
    repo = "my-tool";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  npmDepsHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

  meta = with lib; {
    description = "A CLI tool that does something useful";
    homepage = "https://github.com/example/my-tool";
    license = licenses.mit;
    maintainers = [ "lmdevv" ];
    mainProgram = "my-tool";
  };
}
```

### Getting npmDepsHash

Set `npmDepsHash = "";` initially, then build. Nix will error with the correct hash:

```bash
nix build .#my-tool 2>&1 | grep "got:"
```

### With Native Addons

```nix
nativeBuildInputs = [ python3 pkg-config ];
buildInputs = [ openssl ];
```

### Skipping Postinstall Scripts

```nix
npmFlags = [ "--ignore-scripts" ];
postInstall = ''
  # Manual setup if needed
'';
```

### Custom npm Build Script

```nix
npmBuildScript = "build:production";
npmFlags = [ "--legacy-peer-deps" ];
```

### node2nix (Legacy, Use Only When Necessary)

Use only when `buildNpmPackage` doesn't work (complex native dependencies, custom node versions, workspace monorepos).

```bash
nix-shell -p node2nix
node2nix -12 -l package-lock.json -c node2nix/default.nix
```

### Common Pitfalls

| Issue | Solution |
|---|---|
| `npmDepsHash` mismatch | Delete hash, rebuild, copy correct hash from error |
| ERESOLVE errors | Add `npmFlags = [ "--legacy-peer-deps" ];` |
| Native addon build fails | Add `python3`, `pkg-config` to nativeBuildInputs |
| Postinstall downloads binary | Add `npmFlags = [ "--ignore-scripts" ];` and manually handle |
| Binary name differs from package name | Add `meta.mainProgram = "actual-bin-name";` |

---

## Binary Release Packaging

Package pre-built binaries from GitHub releases, download pages, or API endpoints.

### Pattern A: Multi-Platform Binary with Per-System Hashes

The most common pattern in this NUR:

```nix
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  ...
}:

let
  version = "1.2.3";

  os =
    if stdenv.hostPlatform.isLinux then
      "linux"
    else if stdenv.hostPlatform.isDarwin then
      "darwin"
    else
      throw "my-tool: unsupported OS ${stdenv.hostPlatform.system}";

  arch =
    if lib.hasPrefix "x86_64" stdenv.hostPlatform.system then
      "x64"
    else if
      lib.hasPrefix "aarch64" stdenv.hostPlatform.system
      || lib.hasPrefix "arm64" stdenv.hostPlatform.system
    then
      "arm64"
    else
      throw "my-tool: unsupported arch ${stdenv.hostPlatform.system}";

  sha256BySystem = {
    "x86_64-linux" = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    "aarch64-linux" = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
    "x86_64-darwin" = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=";
    "aarch64-darwin" = "sha256-DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=";
  };

  srcUrl = "https://github.com/owner/repo/releases/download/v${version}/my-tool-v${version}-${os}-${arch}.tar.gz";
  srcHash =
    sha256BySystem.${stdenv.hostPlatform.system}
      or (throw "my-tool: missing sha256 for ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "my-tool";
  inherit version;

  src = fetchurl {
    url = srcUrl;
    sha256 = srcHash;
  };

  sourceRoot = ".";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp my-tool $out/bin/my-tool
    chmod +x $out/bin/my-tool
    runHook postInstall
  '';

  doCheck = false;

  meta = with lib; {
    description = "A CLI tool that does something";
    homepage = "https://github.com/owner/repo";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "my-tool";
    maintainers = [ "lmdevv" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
```

### Pattern B: Single Binary (No Per-Platform)

```nix
stdenv.mkDerivation rec {
  pname = "my-tool";
  version = "1.2.3";

  src = fetchurl {
    url = "https://example.com/downloads/my-tool-${version}.tar.gz";
    hash = "sha256-AAA...";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp my-tool $out/bin/
    chmod +x $out/bin/my-tool
    runHook postInstall
  '';

  meta = with lib; {
    description = "A CLI tool";
    homepage = "https://example.com";
    license = licenses.unfree;
    mainProgram = "my-tool";
    maintainers = [ "lmdevv" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
```

### Pattern C: AppImage + DMG

For desktop applications:

```nix
let
  sources = {
    x86_64-linux = fetchurl { url = "..."; hash = "sha256-..."; };
    x86_64-darwin = fetchurl { url = "..."; hash = "sha256-..."; };
    aarch64-darwin = fetchurl { url = "..."; hash = "sha256-..."; };
  };
  source = sources.${stdenv.hostPlatform.system};

  linux = appimageTools.wrapType2 {
    inherit pname version; src = source;
    extraInstallCommands = '' ... '';
  };

  darwin = stdenv.mkDerivation {
    inherit pname version; src = source;
    nativeBuildInputs = [ undmg ];
    sourceRoot = "MyApp.app";
    installPhase = '' ... '';
    dontFixup = true;
  };
in
(if stdenv.hostPlatform.isDarwin then darwin else linux).overrideAttrs (_: {
  passthru = { inherit sources; updateScript = ./update.sh; };
  meta = { ... };
})
```

### Extracting Binary from curl Install Script

1. Download and read the install script: `curl -fsSL https://example.com/install.sh`
2. Find the download URL construction (look for `curl`, `wget`, URL variables)
3. Determine platform mapping (how OS/arch maps to URLs)
4. Find version resolution (API endpoint, redirect, or hardcoded)
5. Prefetch hashes for each platform

```bash
# Read the install script
curl -fsSL https://example.com/install.sh | head -200

# Prefetch hashes
nix store prefetch-file --json "https://releases.example.com/v1.2.3/linux/x64/binary"
```

### Prefetching Hashes

```bash
# Single file
nix store prefetch-file --json "https://example.com/download/v1.2.3/tool-linux-x64.tar.gz"

# All platforms
for sys in x86_64-linux aarch64-linux x86_64-darwin aarch64-darwin; do
  url=$(construct_url "$sys")
  hash=$(nix store prefetch-file --json "$url" | python3 -c 'import sys, json; d=json.load(sys.stdin); print(d.get("hash") or d["narHash"])')
  echo "$sys: $hash"
done
```

---

## GitHub Source Builds

Package projects by building from source when no binary releases are available.

### Go Projects

```nix
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "my-tool";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "example";
    repo = "my-tool";
    rev = "v${version}";
    hash = "sha256-AAA...";
  };

  vendorHash = "sha256-BBB...";

  meta = with lib; {
    description = "A Go-based CLI tool";
    homepage = "https://github.com/example/my-tool";
    license = licenses.mit;
    maintainers = [ "lmdevv" ];
    mainProgram = "my-tool";
  };
}
```

### Rust Projects

```nix
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "my-tool";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "example";
    repo = "my-tool";
    rev = "v${version}";
    hash = "sha256-AAA...";
  };

  cargoHash = "sha256-BBB...";

  meta = with lib; {
    description = "A Rust-based CLI tool";
    homepage = "https://github.com/example/my-tool";
    license = licenses.mit;
    maintainers = [ "lmdevv" ];
    mainProgram = "my-tool";
  };
}
```

### Getting Hash Values

Set hash to empty string, build, and Nix will report the correct value:

```bash
# Start: hash = "";
nix build .#my-tool
# Error will show the expected hash
```

---

## Creating and Registering Derivations

### File Structure

```
pkgs/<package-name>/
└── default.nix          # Required: the derivation
```

Optionally with `update.sh` or `scripts/update-<name>.sh`.

### Registration

Add to root `default.nix`:

```nix
{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  my-tool = pkgs.callPackage ./pkgs/my-tool { };
}
```

**Do NOT** use reserved names `lib`, `modules`, or `overlays` as package names.

### Required Meta Attributes

```nix
meta = with lib; {
  description = "Short one-line description";
  homepage = "https://github.com/owner/repo";
  license = licenses.mit;
  maintainers = [ "lmdevv" ];
  mainProgram = "my-tool";
  platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
};
```

Additional fields when applicable: `longDescription`, `changelog`, `sourceProvenance`.

### Convention Checklist

- [ ] `pname` matches directory name under `pkgs/`
- [ ] `version` is a proper version string
- [ ] Hashes are real SRI hashes (not placeholders)
- [ ] `meta.description` is concise (no period at end)
- [ ] `meta.license` uses `lib.licenses` attribute
- [ ] `meta.mainProgram` matches installed binary name
- [ ] Package is registered in root `default.nix`
- [ ] Binary packages include `sourceProvenance`
- [ ] Linux-only patches use `lib.optionals stdenv.hostPlatform.isLinux`
- [ ] macOS derivations set `dontFixup = true` when appropriate

### Install Phase Patterns

Single binary:
```nix
installPhase = ''
  runHook preInstall
  mkdir -p $out/bin
  cp my-tool $out/bin/my-tool
  chmod +x $out/bin/my-tool
  runHook postInstall
'';
```

Directory layout:
```nix
installPhase = ''
  runHook preInstall
  mkdir -p $out/lib/my-tool
  cp -a ./* $out/lib/my-tool/
  mkdir -p $out/bin
  ln -s $out/lib/my-tool/my-tool $out/bin/my-tool
  runHook postInstall
'';
```

With wrapper:
```nix
nativeBuildInputs = [ makeWrapper ];

postInstall = ''
  makeWrapper $out/lib/my-tool/my-tool $out/bin/my-tool \
    --prefix PATH : "${lib.makeBinPath [ git coreutils ]}" \
    --set MY_TOOL_HOME "$out/lib/my-tool"
'';
```

---

## Testing Builds

### Build Commands

```bash
nix build .#my-tool                                          # Basic build
NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#my-tool       # Unfree packages
nix build .#packages.x86_64-linux.my-tool                   # Specific system
```

### Basic Verification

```bash
./result/bin/my-tool --version
./result/bin/my-tool --help
```

### Check Closure Size and Dependencies

```bash
nix path-info -S ./result          # Closure size
nix-store -qR ./result              # Dependencies
nix-store -q --references ./result  # Runtime references
```

### Common Build Errors

| Error | Fix |
|---|---|
| Hash mismatch | Update hash from error message |
| Missing dependencies (Linux) | Add libs to `buildInputs`, use `ldd` to find them |
| Permission denied | Add `chmod +x` in `installPhase` |
| Attribute missing | Register package in root `default.nix` |

### Pre-Flight Checklist

- [ ] `nix build .#<name>` succeeds
- [ ] `./result/bin/<name> --version` works
- [ ] No unnecessary dependencies
- [ ] License is correctly set
- [ ] All platform hashes are correct
- [ ] Package registered in root `default.nix`

---

## Update Automation

### Update Script Template

```bash
#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://example.com/releases"
NIX_FILE="pkgs/my-tool/default.nix"

die() { echo "error: $*" >&2; exit 1; }

REPO_ROOT=$(git rev-parse --show-toplevel)
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
  if [ -n "${FORCE_VERSION:-}" ]; then
    echo "$FORCE_VERSION"
    return 0
  fi
  curl -fsSL "https://api.github.com/repos/OWNER/REPO/releases/latest" \
    | python3 -c 'import sys, json; print(json.load(sys.stdin)["tag_name"].lstrip("v"))'
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

  sed -i -E "s#(^[[:space:]]*version[[:space:]]*=[[:space:]]*\")([^\"]+)(\";)#\\1${new_version}\\3#" "$NIX_FILE"
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
    echo "warning: could not discover latest version." >&2
    [ -n "${FORCE_VERSION:-}" ] && ver="$FORCE_VERSION" || exit 0
  fi

  if [ "$ver" = "$cur" ]; then
    echo "my-tool is already up-to-date ($ver)."
    exit 0
  fi

  echo "Updating my-tool: $cur -> $ver"

  declare -A OS_BY_SYSTEM=(
    [x86_64-linux]=linux  [aarch64-linux]=linux
    [x86_64-darwin]=darwin [aarch64-darwin]=darwin
  )
  declare -A ARCH_BY_SYSTEM=(
    [x86_64-linux]=x64   [aarch64-linux]=arm64
    [x86_64-darwin]=x64  [aarch64-darwin]=arm64
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

  update_nix_file "$ver" \
    "${HASH[x86_64-linux]}" "${HASH[aarch64-linux]}" \
    "${HASH[x86_64-darwin]}" "${HASH[aarch64-darwin]}"

  echo "Update complete."
}

main "$@"
```

### GitHub Actions Workflow

Create `.github/workflows/update-<name>.yml`:

```yaml
name: update-my-tool
on:
  schedule:
    - cron: '0 6 * * *'
  workflow_dispatch:
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

### Version Discovery Methods

| Source | Command |
|---|---|
| GitHub releases (latest) | `curl -sL https://api.github.com/repos/OWNER/REPO/releases/latest \| jq -r '.tag_name \| ltrimstr("v")'` |
| GitHub tags | `curl -sL https://api.github.com/repos/OWNER/REPO/tags \| jq -r '.[0].name \| ltrimstr("v")'` |
| npm registry | `curl -sL https://registry.npmjs.org/PACKAGE/latest \| jq -r '.version'` |
| Crates.io | `curl -sL https://crates.io/api/v1/crates/CRATE \| jq -r '.crate.max_version'` |
| PyPI | `curl -sL https://pypi.org/pypi/PACKAGE/json \| jq -r '.info.version'` |
| Custom VERSION file | `curl -fsSL https://example.com/latest/VERSION` |