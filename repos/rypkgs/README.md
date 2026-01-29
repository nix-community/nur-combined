# rypkgs

Personal [NUR](https://github.com/nix-community/NUR) repository.

![Build and populate cache](https://github.com/Ryder-C/rypkgs/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-ryderc-blue.svg)](https://ryderc.cachix.org)

## Usage

Add to your flake inputs:

```nix
{
  inputs.rypkgs.url = "github:Ryder-C/rypkgs";
}
```

Then access packages via `inputs.rypkgs.packages.${system}.<package-name>`.

### Binary Cache

To use pre-built binaries, add the cachix cache:

```nix
{
  nix.settings = {
    substituters = [ "https://ryderc.cachix.org" ];
    trusted-public-keys = [ "ryderc.cachix.org-1:7iQfIhx9GYXX/LW/P/SHlQo8wwaptTsG0YyfR2gOsLg=" ];
  };
}
```

Or with the cachix CLI:

```bash
cachix use ryderc
```

### With NUR

```nix
{
  inputs.nur.url = "github:nix-community/NUR";
}
```

Then use `nur.repos.rypkgs.<package-name>`.

## Packages

| Package | Description |
|---------|-------------|
| `blink` | A modern Jellyfin desktop client |
| `bluevein` | Bluetooth device synchronization service for dual-boot systems |

## Modules

| Module | Description |
|--------|-------------|
| `bluevein` | `services.bluevein.enable` — runs the BlueVein sync service |

> [!NOTE]
> Packages are only tested against `nixpkgs-unstable`.
