# mattrobenolt's nixpkgs

Custom Nix packages that get updated faster than nixpkgs-unstable. Everything here updates automatically via GitHub Actions.

## Packages

### Go

Official Go binaries from golang.org, updated daily. Following the `-bin` naming convention (like `terraform-bin`), these packages use pre-built binaries instead of building from source.

Available packages:
- `go-bin` - Latest Go version
- `go-bin_1_25` - Go 1.25.x
- `go-bin_1_24` - Go 1.24.x

When new Go versions are released, they show up here automatically. The overlay detects new versions, downloads them, generates hashes, and commits the changes daily at 2 AM UTC.

These packages are named differently from nixpkgs' `go` to avoid invalidating your binary cache. Use them in devShells for fast updates without rebuilding everything that depends on Go.

See [`pkgs/go/README.md`](./pkgs/go/README.md) for implementation details.

### zlint

- `zlint` - Latest stable release (pre-built binary)
- `zlint-unstable` - Built from HEAD

## Usage

Add this repo as a flake input and apply the overlay:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    mattrobenolt-nixpkgs = {
      url = "github:mattrobenolt/nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, mattrobenolt-nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ mattrobenolt-nixpkgs.overlays.default ];
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.go-bin  # Latest Go
          pkgs.zlint
        ];
      };
    };
}
```

## Local development

```bash
nix develop

# Update Go versions (happens automatically via GitHub Actions)
just update-go

# Build packages
nix build .#go-bin
nix build .#go-bin_1_24
nix build .#zlint

# Run packages
nix run .#go-bin -- version
```

## Project Templates

```bash
# Go project
nix flake init -t github:mattrobenolt/nixpkgs#go

# Zig project
nix flake init -t github:mattrobenolt/nixpkgs#zig

# Bun project
nix flake init -t github:mattrobenolt/nixpkgs#bun

# Python project
nix flake init -t github:mattrobenolt/nixpkgs#python
```

## How updates work

A GitHub Actions workflow runs daily and:

1. Scrapes go.dev for all available versions
2. Finds the latest patch for each minor version (1.24.x, 1.25.x, etc.)
3. Generates SRI hashes for all platforms (Linux, macOS, x86_64, ARM64)
4. Commits changes to `versions.json` and `hashes.json`

The flake reads these JSON files and dynamically creates packages for each version. New Go releases appear here the next day without any code changes.

## Development

```bash
just fmt    # Format Nix files
just lint   # Run linters
just check  # Check everything
```

## License

MIT
