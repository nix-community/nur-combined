# nur-packages

**Dagger [NUR](https://github.com/nix-community/NUR) repository**

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/dagger/nix/workflows/Build%20and%20populate%20cache/badge.svg)

## Usage

### As flake

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    dagger.url = "github:dagger/nix";
    dagger.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, dagger, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {inherit system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [ dagger.packages.${system}.dagger ];
        };
      });
}
```
