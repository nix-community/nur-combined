# Analyzing a Project

Before writing any Nix code, analyze the input to determine what kind of project it is and how it should be packaged.

## Input Types

The agent receives one of:
- A **GitHub URL** (e.g., `https://github.com/owner/repo`)
- A **npm package name** (e.g., `typescript`, `prettier`)
- A **direct download URL** (e.g., a binary or archive)
- A **project name** to search for

## Analysis Steps

### 1. Identify the Project Type

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

### 2. Check for Binary Releases First

Always prefer pre-built binaries over source builds when possible. They are:
- Faster to build (no compilation step)
- More reliable (tested by upstream)
- Simpler to maintain

Check these locations for binary releases:
1. GitHub Releases: `https://github.com/owner/repo/releases`
2. npm `preinstall` or `postinstall` scripts that download binaries
3. Project website/download page

### 3. Determine Platform Matrix

For binary releases, determine which platforms are supported:

```
Common platform matrix:
├── x86_64-linux   (most common)
├── aarch64-linux  (ARM Linux)
├── x86_64-darwin  (Intel macOS)
└── aarch64-darwin  (Apple Silicon macOS)
```

Check the release assets for naming patterns:
- `*-linux-amd64*`, `*-linux-x64*`, `*-x86_64-linux*` → x86_64-linux
- `*-linux-arm64*`, `*-linux-arm64*`, `*-aarch64-linux*` → aarch64-linux
- `*-darwin-amd64*`, `*-macos-x64*`, `*-x86_64-macos*` → x86_64-darwin
- `*-darwin-arm64*`, `*-macos-arm64*`, `*-aarch64-macos*` → aarch64-darwin

### 4. Determine Package Name

Choose a Nix-friendly package name:
- Use lowercase
- Replace spaces and special chars with hyphens
- Keep it short and recognizable
- Must be a valid Nix identifier (letters, digits, hyphens between letters)

```
Examples:
  "My Tool" → "my-tool"
  "typescript" → "typescript"
  "@scope/package" → "scope-package" (or keep scoped if using node2nix)
```

### 5. Check License and Metadata

From README, package.json, or LICENSE file:
- `license`: map to `lib.licenses` attribute (e.g., `licenses.mit`, `licenses.asl20`, `licenses.unfree`)
- `description`: short, one-line description of what the tool does
- `homepage`: project website or GitHub repo URL
- `changelog`: URL to changelog if available

### 6. Check for Existing Nix Packages

Before packaging, check if it already exists in nixpkgs:
```bash
nix search nixpkgs <name>
```

If it exists in nixpkgs, consider whether the NUR version adds value (different version, unfree build, extra features).

## Decision Matrix

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

## Example: Analyzing a GitHub Repo

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