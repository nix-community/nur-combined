# SignalRidge NUR Packages

[![Build Status](https://github.com/signalridge/nur-packages/workflows/Build/badge.svg)](https://github.com/signalridge/nur-packages/actions)

Nix User Repository packages maintained by SignalRidge.

## Packages

- **clinvk** - Unified AI CLI wrapper for multiple backends (Claude, Codex, Gemini)
- **sing-box** - sing-box with F5 OpenConnect patches, synced from [sing-box-patches](https://github.com/signalridge/sing-box-patches)

## Usage

### With Flakes

```nix
{
  inputs.nur.url = "github:nix-community/NUR";
  
  # Then use: inputs.nur.repos.signalridge.clinvk
}
```

Or directly:

```bash
nix profile install github:signalridge/nur-packages#clinvk
nix run github:signalridge/nur-packages#clinvk -- --help
```

### Without Flakes

```nix
{ pkgs, ... }:
let
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/tarball/master") {
    inherit pkgs;
  };
in
{
  environment.systemPackages = [ nur.repos.signalridge.clinvk ];
}
```
