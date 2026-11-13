# nur-packages (tylerstyle)

**tylerstyle's [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/tylerstyle/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

## Packages

- **`dfcore`**: Shared forensic safety core for the df tools (protected-device registry `dfcore-protect`, hash-chained audit log `dfcore-audit`). Dual-licensed under MIT OR Apache-2.0.
- **`dfdisk`**: Modern forensic disk imaging, damaged media rescue and conversion CLI/TUI tool. Dual-licensed under MIT OR Apache-2.0.

## Binary cache

The packages are built daily against `nixpkgs-unstable`, `nixos-unstable` and the current
stable channel, and the results are pushed to [Cachix](https://tylerstyle.cachix.org). With
the cache enabled you download them instead of compiling:

```bash
cachix use tylerstyle
```

or in a NixOS configuration:

```nix
nix.settings.extra-substituters = [ "https://tylerstyle.cachix.org" ];
nix.settings.extra-trusted-public-keys = [
  "tylerstyle.cachix.org-1:LPNllLpkzqd8U9T9LE7zj7CjXShPpapyTruShQ3V8hw="
];
```

A download only happens when your nixpkgs is at a revision the packages were built against
(the head of one of those channels at build time); otherwise Nix builds locally as before.

## Installation & Usage

### Ad-hoc with `nix-shell`:
```bash
nix-shell -p nur.repos.tylerstyle.dfdisk
```

### In NixOS configuration (`configuration.nix`):
```nix
nixpkgs.config.packageOverrides = pkgs: {
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    inherit pkgs;
  };
};

environment.systemPackages = [
  pkgs.nur.repos.tylerstyle.dfdisk
];
```

### With Flakes:
```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  nur.url = "github:nix-community/NUR";
};
```
