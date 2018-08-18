{ pkgs ? import <nixpkgs> {} }: with pkgs.lib;

let

  module-list = [
    ./modules/hydra.nix
    ./modules/weechat.nix
  ];

in

  {
    ### PACKAGES
    gianas-return = pkgs.callPackage ./pkgs/gianas-return { };

    overlays = {
      sudo = self: super: {
        sudo = super.sudo.override { withInsults = true; };
      };

      termite = import ./pkgs/termite/overlay.nix;

      sql-developer = import ./pkgs/sqldeveloper/overlay.nix;
    };

    ### MODULES
    modules = let
      nameFromPath = path: replaceStrings [ ".nix" ] [ "" ] (last (splitString "/" (toString path)));
    in
      listToAttrs (map (path: { name = "${nameFromPath path}"; value = import path; }) module-list);

    ### LIBRARY
    lib = pkgs.callPackage ./lib { };
  }
