# nur-packages

Personal [NUR](https://github.com/nix-community/NUR) repository.

## Packages

- **librepods**: LibrePods Linux app (Qt6) — AirPods controls and battery monitoring.
  - Upstream: `https://github.com/kavishdevar/librepods`
- **looking-glass-client**: Looking Glass client.
  - Upstream: `https://github.com/gnif/LookingGlass`

## Usage

See the official NUR installation docs: [NUR documentation – Installation](https://nur.nix-community.org/documentation/#installation).

### Usage (flakes)

If you want to use this repo directly as a flake input:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chiasson.url = "git+https://git.chiasson.cloud/Olivier/nur-packages";
  };

  outputs = { self, nixpkgs, chiasson, ... }:
    let
      system = "x86_64-linux";
    in
    {
      packages.${system}.default = chiasson.packages.${system}.librepods;
    };
}
```

### Usage (local build/test)

From this repository:

```bash
nix build .#librepods
./result/bin/librepods
```

