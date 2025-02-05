# nur-packages

**My personal [NUR repository](https://nur.nix-community.org/repos/dcsunset/)**

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/DCsunset/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

## Usage

You can follow the [NUR guide](https://github.com/nix-community/NUR#how-to-use) to import the whole NUR namespace
and use the repo as `nur.repos.dcsunset`.
This will use the official build of this NUR repo.

To use this repo directly (latest) without the whole NUR namespace,
add the following to your `flake.nix` config:

```nix
{
  inputs = {
    nur-dcsunset = {
      url = "github:DCsunset/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Add packages from this repo
        {
          nixpkgs.overlays = [ inputs.nur-dcsunset.overlays.pkg ];
        }
      ];
    };
  };
}
```

## Acknowledgement

Some of the modules and packages are derived from nixpkgs for testing or applying minor fixes.
Thanks to nixpkgs contributors!

