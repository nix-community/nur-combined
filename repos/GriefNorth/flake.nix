{
  description = "GriefNorth's NUR packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      eachSystem = flake-utils.lib.eachDefaultSystem;
    in
    (eachSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages = {
          throne = pkgs.callPackage ./pkgs/throne { };
          teambridge = pkgs.callPackage ./pkgs/teambridge { };
          torrserver = pkgs.callPackage ./pkgs/torrserver { };
        };
      }
    ))
    // {
      nixosModules = import ./modules;
      homeModules = import ./hm-modules;
    };
}
