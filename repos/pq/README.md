# hostwithquantum/nur

![Build and populate cache](https://github.com/hostwithquantum/nur/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-hostwithquantun-blue.svg)](https://hostwithquantum.cachix.org)

A nix user repository to install the runway CLI.

## Usage

### Run with nix shell

Install the Flake in a nix shell using the `nix shell` command.

```bash
nix shell --impure github:hostwithquantum/nur/11a8e8f0ac6de019565da086820c4b8709532516#runway
```

where
- `/11a8e8f0ac6de019565da086820c4b8709532516` indicates a specific commit that you want to reference (which you should be free to drop if you just want to install the mainline version)
- `--impure` allows the use of unfree packages by setting the env var `NIXPKGS_ALLOW_UNFREE=1` (note that env vars are only visible to nix on _impure_ runs)

### Run from Flake with `nix develop`

In case you want to install runway as part of an existing Flake, for example in your dev env that is managed by a flake, specify the runway flake as an input and list it as a `buildInput` in your devShell.

```nix
{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    runway = {
      url = "github:hostwithquantum/nur/11a8e8f0ac6de019565da086820c4b8709532516";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, runway }: flake-utils.lib.eachDefaultSystem (system:
    let pkgs = import nixpkgs { inherit system; }; in
    {

      packages.hello = nixpkgs.legacyPackages.${system}.hello;

      defaultPackage = self.packages.${system}.hello;

      devShell = with pkgs; mkShell {
        buildInputs = [ runway.legacyPackages.${system}.runway ];
      };
    });
}
```

Spin up the `nix develop` shell using the following command:

```bash
NIXPKGS_ALLOW_UNFREE=1 nix develop --impure
```
