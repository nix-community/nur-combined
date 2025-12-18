# Go Overlay

Automated Go releases that update faster than nixpkgs-unstable.

## How it works

This overlay is maintenance-free:

- Detects all available Go minor versions (1.24, 1.25, 1.26, etc.)
- Tracks the latest prerelease (RC/beta) as `go-bin_next`
- Updates daily via GitHub Actions
- Creates packages dynamically (`go-bin_1_24`, `go-bin_1_25`, etc.)
- Commits when new versions are available

When Go 1.26 is released, `go-bin_1_26` will show up automatically.

## Available Packages

Packages are created dynamically from the latest available Go versions:

- `go-bin` - Latest stable Go version (points to highest minor version)
- `go-bin_next` - Latest prerelease (RC/beta) for testing upcoming features
- `go-bin_1_25` - Go 1.25.x (latest patch)
- `go-bin_1_24` - Go 1.24.x (latest patch)
- Future versions appear automatically

Check current versions:
```bash
cat pkgs/go/versions.json
```

## Daily Automation

GitHub Actions runs daily at 2 AM UTC:

1. Scrapes go.dev for all available stable versions
2. Checks GitHub tags for the latest prerelease (RC/beta)
3. Finds the latest patch for each minor version (1.24.x, 1.25.x, etc.)
4. Downloads and generates SRI hashes for all platforms
5. Commits changes to `versions.json` and `hashes.json`

The flake reads these JSON files and creates packages for each version. No code changes needed when new versions are released.

## Usage

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    mattrobenolt-nixpkgs.url = "github:mattrobenolt/nixpkgs";
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
          pkgs.go-bin        # Latest stable
          # or
          pkgs.go-bin_next   # Latest prerelease (RC/beta)
          # or
          pkgs.go-bin_1_24   # Specific version
        ];
      };
    };
}
```

## Manual Updates

You can manually trigger updates:

```bash
just update-go
```

Or run the script directly:

```bash
./pkgs/go/update.py
```

## Files

- `default.nix` - Package builder (accepts version and hashes)
- `versions.json` - Maps minor versions to latest patch versions
- `hashes.json` - SRI hashes for all versions and platforms
- `update.py` - Automated update script
- `README.md` - This file
