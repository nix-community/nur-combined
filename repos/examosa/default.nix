{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib;

  packages = lib.packagesFromDirectoryRecursive {
    newScope = extra:
      pkgs.newScope (extra
        // {
          lib = lib.recursiveUpdate pkgs.lib {
            # Missing in nixos-26.05
            maintainers.examosa.github = "examosa";
          };
        });

    directory = ./packages;
  };
in
  packages
  // {
    overlays = import ./overlays;
  }
