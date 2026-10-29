{
  description = "arch-fan NUR packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      inherit (nixpkgs) lib;

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      packages = import ./. { inherit pkgs; };

      appImages = lib.filterAttrs (_: pkg: pkg ? fhsenv && pkg ? contents) packages;
    in
    {
      packages.${system} = packages;

      # `nix flake check` builds every package and verifies that each
      # AppImage's shared libraries resolve inside its FHS env.
      checks.${system} =
        packages
        // lib.mapAttrs' (
          name: package:
          lib.nameValuePair "${name}-libs" (pkgs.callPackage ./checks/appimage-libs.nix { inherit package; })
        ) appImages;

      formatter.${system} = pkgs.nixfmt-tree;

      apps.${system}.update = {
        type = "app";
        program = lib.getExe (
          pkgs.writeShellApplication {
            name = "update";
            runtimeInputs = [ pkgs.nix-update ];
            text = builtins.readFile ./scripts/update.sh;
          }
        );
        meta.description = "Bump every package in pkgs/ to its latest upstream release";
      };
    };
}
