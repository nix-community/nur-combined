# Go Overlay

Automated Go binary releases that update faster than nixpkgs-unstable.

## How it works

This package family is generated from JSON state:

- `versions.json` maps Go minor versions to the latest tracked patch release.
- `hashes.json` stores SRI hashes for every tracked Go release and platform.
- `package.nix` builds one specific Go version from the version/hash pair passed by `lib/packages.nix`.

The updater reads Go's official download API and uses the SHA256 checksums published there. It does not download every Go archive just to discover hashes.

## Available Packages

Packages are created dynamically from the latest available Go versions:

- `go-bin` - Latest stable Go version (points to highest stable minor version)
- `go-bin_next` - Latest prerelease (RC/beta) for testing upcoming features
- `go-bin_1_26` - Go 1.26.x (latest patch)
- `go-bin_1_25` - Go 1.25.x (latest patch)
- `go-bin_1_24` - Go 1.24.x (latest patch)
- Future versions appear automatically

Check current versions:

```bash
cat pkgs/go-bin/versions.json
```

## Daily Automation

GitHub Actions runs daily at 2 AM UTC:

1. Reads go.dev's download API for stable releases and checksums
2. Checks GitHub tags for the latest prerelease (RC/beta)
3. Finds the latest patch for each tracked minor version (1.24.x, 1.25.x, etc.)
4. Converts upstream SHA256 checksums to Nix SRI hashes
5. Commits changes to `versions.json` and `hashes.json`

The flake reads these JSON files and creates packages for each version. No code changes are needed when new versions are released.

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
          pkgs.go-bin_1_24   # Specific minor version
        ];
      };
    };
}
```

## Manual Updates

You can manually trigger updates:

```bash
just update go-bin
```

The old alias still works:

```bash
just update-go
```

Or run the script directly:

```bash
./pkgs/go-bin/update.py
```

## Files

- `package.nix` - Go derivation, parameterized by version and hashes
- `default.nix` - Compatibility shim importing `package.nix`
- `versions.json` - Maps minor versions to latest patch versions
- `hashes.json` - SRI hashes for all versions and platforms
- `update.py` - Automated update script
- `README.md` - This file
