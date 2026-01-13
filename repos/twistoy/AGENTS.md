# Agent Guidelines for nur-packages

This is a NUR (Nix User Repository) containing custom Nix packages and NixOS modules.

## Build, Lint, and Test Commands

### Building Packages

```bash
# Build all packages (default)
nix-build

# Build using justfile
just build

# Build a specify package with flake
nix build .#<package-name>
nix build .#gersemi

# Check flake evaluation
nix flake check

# Show all available packages
nix flake show
```

## Code Style Guidelines

### File Structure

- `pkgs/`: Individual package definitions
- `lib/`: Custom library functions
- `modules/`: NixOS/home-manager modules
- `overlays/`: Nixpkgs overlays
- `default.nix`: Entry point for legacy nix-build
- `flake.nix`: Flake entry point
- `ci.nix`: CI configuration for buildable/cacheable packages

### Package Organization

```
pkgs/
├── default.nix                 # Package set definition using lib.makeScope
├── <package-name>/
│   └── default.nix             # Package definition
└── vim-plugins/
    ├── default.nix             # Vim plugins set
    └── <plugin-name>.nix       # Individual plugin
```

### Naming Conventions

- Package names: lowercase with hyphens (`rime-ls`, `gh-actions-nvim`)
- Attribute names: camelCase for Nix functions, hyphenated for packages
- Use `rec` only when necessary (prefer `let...in` for readability)
- Version format: `"x.y.z"` or `"YYYY-MM-DD"` for date-based

### Hash and Security

- Use SRI hashes: `hash = "sha256-...";` not `sha256 = "...";`
- Update hashes when bumping versions
- For Rust: use `cargoHash`, not `cargoSha256`
- For Git sources: use `rev` with `hash`, not `sha256`

### Error Handling

- Set `doCheck = false;` for packages with failing/network-dependent tests
- Use `lib.optionals` for conditional lists
- Use `lib.optional` for single conditional items
- Handle platform-specific dependencies with `stdenv.isDarwin` checks

```nix
buildInputs = [
  openssl
] ++ lib.optionals stdenv.isDarwin [
  darwin.apple_sdk.frameworks.Security
];
```

### Meta Attributes

Required meta fields:
- `description`: Brief, clear description (no ending period)
- `homepage`: Project URL
- `license`: Use `lib.licenses.*`

Optional but recommended:
- `maintainers`: Use `lib.maintainers` if applicable
- `platforms`: Specify supported platforms
- `broken`: Set to `true` if package is known broken

## Common Patterns

### Adding a New Package

1. Create `pkgs/<package-name>/default.nix`
2. Add package to `pkgs/default.nix` in the `makeScope` call
3. Test build: `nix-build .#<package-name>`
4. Check evaluation: `nix flake check`
5. Commit with message: `feat: add <package-name>`

### Updating a Package

1. Update `version` and `hash`/`cargoHash`
2. Test build locally
3. Commit with message: `feat: uprev <package-name>` or `feat: update <package-name>`

### Deprecation Warnings

- `useFetchCargoVendor` is now default in 25.05+, remove it
- Use `lib.recurseIntoAttrs` instead of `pkgs.recurseIntoAttrs`
- Prefer `hash` over `sha256` for all fetchers

