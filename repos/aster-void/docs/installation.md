# Installing this Flake

There are two ways to install this flake.

- Use method 1 if your configuration is a flake.
- Use method 2 if your configuration is not a flake yet.

either way, you must have flakes and nix-command enabled.

```sh
$ cat ~/.config/nix/nix.conf
experimental-features = nix-command flakes
```

## Method 1: Using Flake Inputs

### 1. Add to flake inputs

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # add these
    nix-repository.url = "github:aster-void/nix-repository";
    nix-repository.inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

### 2. Pass inputs to the module system

if it's NixOS:

```nix
# flake.nix (partial)
nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs; # <-- add this
  };
  modules = [ ./configuration.nix ];
};
```

if it's Home Manager:

```nix
# flake.nix (partial)
homeConfigurations.username = home-manager.lib.homeManagerConfiguration {
  extraSpecialArgs = {
    inherit inputs; # <-- add this
  };
  modules = [ ./home.nix ];
};
```

and you're ready to go!

> NOTE: it is also recommended to add binary cache. (see below)

example usage for chrome-devtools-mcp in home manager:

```nix
{inputs, pkgs, ...}: {
  home.packages = [
    inputs.nix-repository.packages.${pkgs.system}.chrome-devtools-mcp
  ];
}
```

## Method 2: Non-Flake Systems

For systems not using flakes:

```nix
# configuration.nix or home.nix
{ pkgs, ... }: let
  nix-repository = builtins.getFlake "github:aster-void/nix-repository";
in {
  # rest of the config...
}
```

or, pin a commit:

```nix
# configuration.nix or home.nix
nix-repository = builtins.getFlake "github:aster-void/nix-repository/COMMIT_REV";
```

## Use the binary cache

```nix
# flake.nix
{
  nixConfig = {
    extra-substituters = ["https://nix-repository--aster-void.cachix.org"];
    extra-trusted-public-keys = ["nix-repository--aster-void.cachix.org-1:A+IaiSvtaGcenevi21IvvODJoO61MtVbLFApMDXQ1Zs="];
  };
}
```
