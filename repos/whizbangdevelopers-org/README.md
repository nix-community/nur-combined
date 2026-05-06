# whizBANG Developers NUR Packages

[![Build](https://github.com/whizbangdevelopers-org/nur-packages/actions/workflows/build.yml/badge.svg)](https://github.com/whizbangdevelopers-org/nur-packages/actions/workflows/build.yml)

Nix User Repository packages from [whizBANG Developers](https://github.com/whizbangdevelopers-org).

## Packages

| Package | Description |
|---------|-------------|
| `qepton` | AI Prompt and Code Snippet Manager powered by GitHub Gist |
| `weaver-free` | NixOS workload isolation — unified container and MicroVM management (Free tier, AGPL-3.0). Weaver Solo / Team / Fabrick are commercial tiers and are not distributed via NUR. |

> **Licensing gate:** This NUR repository distributes **open-source (AGPL-3.0 or MIT) packages only**. Commercial-licensed tiers of whizBANG products (Weaver Solo / Team / Fabrick under BSL-1.1) are distributed through commercial channels and will never appear here.

## Usage

### With Flakes

```nix
{
  inputs.whizbang-nur.url = "github:whizbangdevelopers-org/nur-packages";

  outputs = { self, nixpkgs, whizbang-nur }: {
    # Use in your configuration
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            whizbang-nur.packages.${pkgs.system}.qepton
          ];
        })
      ];
    };
  };
}
```

### With NUR

Once registered with NUR, you can use:

```nix
{ pkgs, ... }:

let
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    inherit pkgs;
  };
in
{
  environment.systemPackages = [
    nur.repos.whizbangdevelopers.qepton
  ];
}
```

### Direct Installation

```bash
# Try it out
nix run github:whizbangdevelopers-org/nur-packages#qepton

# Or build it
nix build github:whizbangdevelopers-org/nur-packages#qepton
```

## Authentication

Qepton requires a GitHub token with `gist` scope. NixOS users have several options:

### Option 1: Import from gh CLI (Recommended)

If you use `gh` CLI with keyring-based auth:

1. Ensure you're logged in: `gh auth login`
2. Launch Qepton and click **"Import from gh CLI"** on the login page

The app will automatically retrieve your token via `gh auth token`.

### Option 2: Manual Token Entry

1. Copy your token: `gh auth token | wl-copy`
2. Paste it into the token field on the login page

### Option 3: Create a Personal Access Token

1. Visit [GitHub Token Settings](https://github.com/settings/tokens/new?scopes=gist&description=Qepton)
2. Generate a token with `gist` scope
3. Enter the token on the login page

## Development

```bash
# Build all packages
nix-build

# Build specific package
nix-build -A qepton

# Enter dev shell
nix develop
```
