{ pkgs ? import <nixpkgs> {} }: with pkgs.lib;

let

  nameFromPath = path: replaceStrings [ ".nix" ] [ "" ] (last (splitString "/" (toString path)));

  module-list = [
    ./modules/hydra.nix
  ];

in

  {
    ### PACKAGES
    gianas-return = pkgs.callPackage ./pkgs/gianas-return { };

    overlays = {
      sudo = import ./pkgs/sudo/overlay.nix;

      termite = import ./pkgs/termite/overlay.nix;

      hydra = import ./pkgs/hydra/overlay.nix;
    };

    ### MODULES
    modules = listToAttrs (map (path: { name = "${nameFromPath path}"; value = import path; }) module-list);

    ### LIBRARY
    lib = pkgs.callPackage ./lib { };
  }
