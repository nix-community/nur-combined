# Creating and Registering Derivations

Step-by-step guide for creating a new package in the NUR repository.

## File Structure

Every package follows this structure:

```
pkgs/<package-name>/
└── default.nix          # Required: the derivation
```

Optionally:

```
pkgs/<package-name>/
├── default.nix          # The derivation
└── update.sh            # Auto-update script (if applicable)
```

Or co-located in `scripts/`:

```
scripts/
└── update-<package-name>.sh
```

## Step-by-Step Process

### 1. Choose the Package Name

The package name must:
- Be lowercase
- Use hyphens (not underscores)
- Be a valid Nix identifier
- Be short and recognizable
- Match the upstream name when possible

```
Good: code-cursor, cursor-agent, my-tool
Bad:  CodeCursor, my_tool, myTool
```

### 2. Create the Derivation

Create `pkgs/<package-name>/default.nix` using the appropriate pattern:

- **Binary release** → Use the multi-platform hash pattern (see [binary-release](binary-release.md))
- **AppImage/DMG** → Use the `appimageTools`/`undmg` pattern
- **npm package** → Use `buildNpmPackage` (see [npm-packaging](npm-packaging.md))
- **Go source** → Use `buildGoModule` (see [github-source](github-source.md))
- **Rust source** → Use `rustPlatform.buildRustPackage`
- **Python source** → Use `python3Packages.buildPythonApplication`

### 3. Register in Root default.nix

Add the package to `/default.nix`:

```nix
{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  # Existing packages
  cursor-agent = pkgs.callPackage ./pkgs/cursor-agent { };
  code-cursor = pkgs.callPackage ./pkgs/code-cursor { };

  # NEW: Add your package
  my-tool = pkgs.callPackage ./pkgs/my-tool { };
}
```

**Important:** Do NOT use reserved names `lib`, `modules`, or `overlays` as package names.

### 4. Fill in Placeholder Hashes

For initial development, use empty/placeholder hashes and let Nix tell you the correct ones:

```nix
# For fetchurl/fetchFromGitHub
hash = "";

# For buildNpmPackage
npmDepsHash = "";

# For buildGoModule
vendorHash = "";

# For buildRustPackage
cargoHash = "";
```

Then build and Nix will error with the expected hash:

```bash
nix build .#my-tool 2>&1 | grep "got:"
```

### 5. Required Meta Attributes

Every package MUST include these meta attributes:

```nix
meta = with lib; {
  description = "Short one-line description";
  homepage = "https://github.com/owner/repo";
  license = licenses.mit;  # or licenses.unfree, licenses.asl20, etc.
  maintainers = [ "lmdevv" ];
  mainProgram = "my-tool";  # the executable name from $out/bin/
  platforms = [  # or use builtins.attrNames sources
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];
};
```

Additional meta attributes when applicable:

```nix
meta = with lib; {
  # ... required fields above ...

  longDescription = ''
    A longer multi-line description of what the tool does,
    its features, and use cases.
  '';

  changelog = "https://github.com/owner/repo/releases/tag/v${version}";

  sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  # Add this for pre-built binary packages
};
```

### 6. Convention Checklist

Before finalizing the derivation, verify:

- [ ] `pname` matches the directory name under `pkgs/`
- [ ] `version` is a proper version string (not a commit hash unless necessary)
- [ ] Hashes are real SRI hashes (not placeholders)
- [ ] `meta.description` is concise (no period at end)
- [ ] `meta.homepage` is a valid URL
- [ ] `meta.license` uses `lib.licenses` attribute
- [ ] `meta.mainProgram` matches the installed binary name
- [ ] `meta.maintainers` includes your handle
- [ ] Package is registered in root `default.nix`
- [ ] Binary packages include `sourceProvenance = with sourceTypes; [ binaryNativeCode ]`
- [ ] Linux-only patches use `lib.optionals stdenv.hostPlatform.isLinux`
- [ ] macOS derivations set `dontFixup = true` when appropriate (preserves code signatures)

## Common Derivation Patterns

### Install Phase for Single Binary

```nix
installPhase = ''
  runHook preInstall
  mkdir -p $out/bin
  cp my-tool $out/bin/my-tool
  chmod +x $out/bin/my-tool
  runHook postInstall
'';
```

### Install Phase for Directory Layout

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

### Install Phase with Wrapper

```nix
nativeBuildInputs = [ makeWrapper ];

installPhase = ''
  runHook preInstall
  mkdir -p $out/lib/my-tool
  cp -a ./* $out/lib/my-tool/
  runHook postInstall
'';

postInstall = ''
  makeWrapper $out/lib/my-tool/my-tool $out/bin/my-tool \
    --prefix PATH : "${lib.makeBinPath [ git coreutils ]}" \
    --set MY_TOOL_HOME "$out/lib/my-tool"
'';
```

### Conditional Platform Logic

```nix
# Only on Linux
nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
  autoPatchelfHook
];

buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
  stdenv.cc.cc.lib
];

# Only on macOS
dontFixup = stdenv.hostPlatform.isDarwin;
```

## Example: Complete New Package

From scratch to complete:

```bash
# 1. Create directory
mkdir -p pkgs/my-tool

# 2. Create default.nix (use appropriate template)

# 3. Register in default.nix
# Add: my-tool = pkgs.callPackage ./pkgs/my-tool { };

# 4. Build with placeholder hashes to get real ones
nix build .#my-tool

# 5. Update with real hashes

# 6. Build again to verify
nix build .#my-tool

# 7. Test the result
./result/bin/my-tool --help
```