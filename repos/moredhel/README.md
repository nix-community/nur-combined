# Moredhel's Packages

This contains all configuration for everything.

- HomeManager configuration
- Custom services
- custom packages
- (Soon?) System Configuration/machine...

## System Configuration

This has a very similar setup to the home-manager config.
The configuration file is very simple:

``` nix
{ config, pkgs, lib, options, ... }:

let
  nur-no-pkgs = ((import ./config.nix).packageOverrides {}).nur.repos.moredhel;
  # nur-no-pkgs = (import /data/src/hub/moredhel/nur-packages { inherit pkgs; });
in
{
  imports = [
    nur-no-pkgs.modules.machines.turtaw
  ];
}
```

## HomeManager Configuration

I have included my entire home-manager configuration into this repository.
This should give me zero regarding keeping it in sync (also as I will be pulling my config remotely).

The below snippet is simply dropped into home.nix, and _almost_ everything should _just work_.

``` nix
# home.nix
{ config ? {}, lib, pkgs, ... }:

let
  # nur-no-pkgs = ((import ./config.nix).packageOverrides {}).nur.repos.moredhel;
  nur-no-pkgs = (import /data/src/hub/moredhel/nur-packages { inherit pkgs; });
in
{
  # example for the pixelbook
  imports = nur-no-pkgs.hm.machines.pixelbook;
}
```

I'm including my ~/.config/nixpkgs/config.nix too so I can easily bootstrap any new computers...

``` nix
let
nur = builtins.fetchTarball {
  url = "https://github.com/nix-community/NUR/archive/fb623226c6c4e51413d7d1478155214a45295332.tar.gz";
  sha256 = "15jgbh4kv1l30zkxccqz9axg4kgxjabj7gc52qj310a60cl20pjy";
};
nur-edge = builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz";
in
{
  allowUnfree = true;
  packageOverrides = pkgs: {
    nur = import nur {
      inherit pkgs;
    };
  };
}
```

