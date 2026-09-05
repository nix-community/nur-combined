# nur-packages (tylerstyle)

**tylerstyle's [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/tylerstyle/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

## Packages

- **`dfdisk`**: Modern forensic disk imaging, damaged media rescue and conversion CLI/TUI tool. Dual-licensed under MIT OR Apache-2.0.

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
