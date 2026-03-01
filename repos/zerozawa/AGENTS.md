# AGENTS.md - Zerozawa's NUR Repository

This is a **Nix User Repository (NUR)** containing custom Nix packages, modules, and overlays.

## Quick Reference

| Command | Description |
|---------|-------------|
| `nix-build -A <package>` | Build a specific package |
| `nix-build ci.nix -A cacheOutputs` | Build all cacheable packages (CI) |
| `nix flake check` | Check flake validity |
| `nix flake show` | Show all flake outputs |
| `nix-instantiate --eval -E '(import <nixpkgs> {}).lib.version'` | Check nixpkgs version |
| `nix build .#<package>` | Build package via flake |

## Project Structure

```
nur/
├── default.nix          # Main entry point - exports all packages
├── flake.nix            # Flake definition (nixpkgs-unstable)
├── ci.nix               # CI build logic - filters buildable/cacheable packages
├── pkgs/                # Package definitions
│   ├── <name>.nix       # Single-file packages
│   └── <name>/          # Multi-file packages (e.g., waybar-vd/)
│       └── default.nix
├── lib/                 # Library functions
├── modules/             # NixOS modules
└── overlays/            # Nixpkgs overlays
```

## Adding a New Package

1. Create `pkgs/<package-name>.nix` (or `pkgs/<package-name>/default.nix` for complex packages)
2. Add to `default.nix`: `<package-name> = pkgs.callPackage ./pkgs/<package-name>.nix {};`
3. Test with: `nix-build -A <package-name>`

## Code Style Guidelines

### Package Definition Pattern

```nix
{
  lib,
  fetchFromGitHub,
  stdenv,
  # ... dependencies
}:
stdenv.mkDerivation rec {
  pname = "package-name";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "...";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-...";
  };

  # Use runHook in phases
  buildPhase = ''
    runHook preBuild
    # build commands
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/..."
    # install commands
    runHook postInstall
  '';

  meta = with lib; {
    description = "Short description";
    homepage = "https://...";
    platforms = platforms.linux;  # or specific like: (intersectLists x86_64 linux)
    license = with licenses; [mit];  # Always use list form
    sourceProvenance = with sourceTypes; [fromSource];  # or binaryBytecode
    mainProgram = pname;  # if applicable
  };
}
```

### Formatting Rules

- Use `alejandra` or `nixpkgs-fmt` for formatting
- Use `let ... in` for local bindings, placed BEFORE the derivation
- Prefer `inherit` for passing through attributes
- Use `rec` only when self-referencing is needed
- Quote paths with spaces: `"$out/share/..."`
- Always include `meta` block with: `description`, `homepage`, `platforms`, `license`, `sourceProvenance`

### Import Style

```nix
# Function arguments - one per line, alphabetized, with trailing comma
{
  fetchFromGitHub,
  lib,
  stdenv,
  ...
}: 
```

### Hash Formats

- Use SRI format: `hash = "sha256-...";` (preferred)
- Or named: `sha256 = "...";`
- Get hash: `nix-prefetch-url --unpack <url>` or let build fail and copy

### Builder-Specific Patterns

**Go packages:**
```nix
buildGoModule rec {
  vendorHash = "sha256-...";
  ldflags = ["-s" "-w" "-X main.version=${version}"];
  doCheck = false;  # if network required
}
```

**Rust packages:**
```nix
rustPlatform.buildRustPackage rec {
  cargoLock.lockFile = ./Cargo.lock;
  postPatch = ''ln -s ${./Cargo.lock} Cargo.lock'';
}
```

**AppImage packages:**
```nix
appimageTools.wrapAppImage {
  src = appimageTools.extract { inherit pname version src; };
  extraPkgs = pkgs: [ ... ];
}
```

**Flutter packages:**
```nix
flutter.buildFlutterApplication rec {
  pubspecLock = importYaml "${src}/pubspec.lock";
  gitHashes = { ... };
}
```

## Testing

### Local Testing
```bash
# Build single package
nix-build -A <package>

# Build with specific nixpkgs
nix-build -A <package> --arg pkgs 'import <nixpkgs> {}'

# Test flake build
nix build .#<package>
```

### CI Testing
```bash
# Build all CI outputs (what GitHub Actions runs)
nix-build ci.nix -A cacheOutputs

# With uncached builder (faster CI)
nix shell -f '<nixpkgs>' nix-build-uncached -c nix-build-uncached ci.nix -A cacheOutputs
```

## CI/CD

- **GitHub Actions**: Runs on push/PR to main/master
- **Cachix**: `zerozawa.cachix.org` - binary cache
- **NUR**: Auto-updates via `nur-update.nix-community.org`

### Package Filters in CI

Packages are automatically filtered based on:
- `meta.broken = true` - Excluded from builds
- `meta.license.free = false` - Excluded (unfree)
- `preferLocalBuild = true` - Excluded from cache

## Common Pitfalls

1. **IFD (Import From Derivation)**: Packages using `builtins.readFile` on derived paths fail in pure evaluation. Mark with `preferLocalBuild = true` if unavoidable.

2. **Missing hashes**: Use `lib.fakeHash` as placeholder, run build, copy real hash from error.

3. **Platform restrictions**: Use `lib.platforms` helpers:
   ```nix
   platforms = with platforms; (intersectLists x86_64 linux);
   ```

4. **License format**: Always use list form even for single license:
   ```nix
   license = with licenses; [mit];  # NOT: license = licenses.mit;
   ```

## Nix Language Tips

```nix
# Conditional inclusion
nativeBuildInputs = [ pkg-config ] 
  ++ lib.optionals cudaSupport [ cudaPackages.cuda_nvcc ];

# String interpolation
rev = "v${version}";

# Attribute access with default
(p.meta or {}).platforms or platforms.none

# Filter attributes
lib.filterAttrs (n: v: lib.isDerivation v) attrs
```

## External Resources

- [NUR](https://github.com/nix-community/NUR) - Nix User Repository
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/) - Package guidelines
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Learning Nix
