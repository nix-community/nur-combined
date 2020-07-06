{ sources ? import ./nix
, lib ? sources.lib
, pkgs ? sources.pkgs { }
, pkgs-unstable ? sources.pkgs-unstable { }
, nixpkgs ? sources.nixpkgs { }
}:
with builtins; with lib;
let
  /*
  mkNixOS: make a nixos system build with the given name and cfg.

  cfg is an attributeSet:
  - arch is architecture
  - type is weither we want to use nixos (stable) or nixos-unstable

  Example:
    hokkaido = { arch = "x86_64-linux"; };
    honshu = { arch = "x86_64-linux"; type = "unstable"; };
  */
  mkNixOS = name: cfg:
    let
      configuration = ./systems + "/${name}.nix";
      system = cfg.arch;
      # If type == unstable, use nixos-unstable (pkgs-unstable) otherwise use nixos (pkgs)
      p =
        if cfg ? type && cfg.type == "unstable"
        then pkgs-unstable
        else pkgs;
      # If vm == true, build a VM, otherwise build the system
      nixos = import (p.path + "/nixos") { inherit configuration system; };
      main =
        if cfg ? vm && cfg.vm
        then nixos.vm
        else nixos.config.system.build;
    in
    main;
  mkSystem = name: cfg:
    if cfg ? vm && cfg.vm
    then (mkNixOS name cfg)
    else (mkNixOS name cfg).toplevel;
  # mkDigitalOceanImage = name: arch: (mkNixOS name arch).digitalocean

  systemAttrs = (mapAttrs mkSystem (import ./hosts.nix));

  filterSystems = arch: attrValues (filterAttrs (_:v: v.system == arch) systemAttrs);
  x86_64Systems = filterSystems "x86_64-linux";
  aarch64Systems = filterSystems "aarch64-linux";
  allSystems = attrValues systemAttrs;
in
{
  systems = nixpkgs.linkFarmFromDrvs "systems" allSystems;
  aarch64 = nixpkgs.linkFarmFromDrvs "aarch64" aarch64Systems;
  x86_64-linux = nixpkgs.linkFarmFromDrvs "x86_64-linux" x86_64Systems;
} // systemAttrs
