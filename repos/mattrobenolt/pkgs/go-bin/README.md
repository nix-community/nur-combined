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
- `go-bin_next` - Latest prerelease (RC/beta), when one is available
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
          pkgs.go-bin_next   # Latest prerelease (RC/beta), when available
          # or
          pkgs.go-bin_1_24   # Specific minor version
        ];
      };
    };
}
```

## Selecting a toolchain from go.mod

`pkgs.go-bin.fromGoMod` reads a `go.mod` or `go.work` file and returns the toolchain named by it. It is the Go counterpart of `rust-bin.fromRustupToolchainFile`.

```nix
devShells.default = pkgs.mkShell {
  packages = [
    (pkgs.go-bin.fromGoMod ./go.mod)
    pkgs.gopls
  ];
};
```

Resolution rules:

1. A `toolchain goVERSION` directive wins, because it is the toolchain cmd/go builds with.
2. Otherwise the `go` directive states a minimum version. The newest tracked patch of that minor is used.
3. A version that matches a tracked release is used unchanged. A version that does not match resolves to the newest tracked patch of the same minor. The build fails if that patch is older than the requested version, because the release database is stale.
4. A custom toolchain name, or a `+suffix`, is an error. The overlay cannot reproduce a toolchain that exists only on one machine.

Resolution reads `versions.json` and `hashes.json` and downloads nothing. A version that is not tracked fails with the list of tracked minor versions.

## Pinning an arbitrary release

`pkgs.go-bin.fromGoRelease` accepts any release published at <https://go.dev/dl/>, including versions the updater does not track. This is the counterpart of `rust-bin.fromRustcRev`: you supply the hash.

```nix
pkgs.go-bin.fromGoRelease {
  version = "1.26.9";
  hashes = {
    "linux-arm64" = "sha256-Spc3PUn8rNzzaU/qNopQCwDuPpY5dPPnUUEycXYy8FI=";
  };
}
```

Supply hashes only for the platforms that get evaluated. Every platform you leave out fails with its own name in the error message. A tracked version needs no hashes, because the database already has them, so this also works for a version the updater knows about.

`just go-hashes VERSION` prints the whole attrset for a release, converted from the checksums that go.dev publishes:

```console
$ just go-hashes 1.26.9
pkgs.go-bin.fromGoRelease {
  version = "1.26.9";
  hashes = {
    "linux-amd64" = "sha256-QtFYtNj3thrAqDBWfJQKhgmPt6rFLkZ6Xr7APvXML40=";
    "linux-arm64" = "sha256-Spc3PUn8rNzzaU/qNopQCwDuPpY5dPPnUUEycXYy8FI=";
    "darwin-amd64" = "sha256-AMKePUyFYvVHQQ2qGNKVm2Qb1pGrAMSlJeqBegJT1L0=";
    "darwin-arm64" = "sha256-+bt8CgJQbF2b8NHrH37mx2hPhErklVgwigQnuDDgIsw=";
  };
}
```

The hash values may also be the bare 64-character `sha256` hex string from go.dev's JSON, so a hash can be copied from the download page without a conversion step.

## Toolchain switching is disabled

Every `go-bin` package wraps `go` and sets `GOTOOLCHAIN=local` when the variable is not already set. cmd/go therefore never downloads a second toolchain. A module that requires a newer release fails at build time:

```text
go: go.mod requires go >= 1.27.0 (running go 1.24.13; GOTOOLCHAIN=local)
```

An explicit `GOTOOLCHAIN` value wins, so `GOTOOLCHAIN=auto` restores the upstream behavior. The real binary stays at `share/go/bin/go` and the wrapper calls it in place, so `go env GOROOT` still reports the package root.

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
- `go-mod.nix` - Toolchain selection from `go.mod`, plus `fromGoRelease`
- `default.nix` - Compatibility shim importing `package.nix`
- `versions.json` - Maps minor versions to latest patch versions
- `hashes.json` - SRI hashes for all versions and platforms
- `update.py` - Automated update script
- `hashes-for.py` - Prints `fromGoRelease` hashes for any release on go.dev
- `README.md` - This file
