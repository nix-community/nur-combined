{
  description = "arch-fan NUR packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Upstream, not nixpkgs' copy: fixes for new Nix releases land here first.
    nix-update = {
      url = "github:Mic92/nix-update";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, nix-update, ... }:
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
            runtimeInputs = [ nix-update.packages.${system}.default ];
            # nix-update evaluates passthru.updateScript via `import <nixpkgs>`:
            # point it at our nixpkgs instead of whatever the caller's NIX_PATH has.
            runtimeEnv.NIX_PATH = "nixpkgs=${nixpkgs}";
            text = builtins.readFile ./scripts/update.sh;
          }
        );
        meta.description = "Bump every package in pkgs/ to its latest upstream release";
      };
    };
}
