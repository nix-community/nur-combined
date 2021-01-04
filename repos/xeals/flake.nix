{
  description = "xeals's flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      inherit (flake-utils.lib) eachDefaultSystem flattenTree;
      inherit (nixpkgs.lib.attrsets) filterAttrs mapAttrs;
    in
    {
      nixosModules = mapAttrs (_: path: import path) (import ./modules);

      overlays = import ./overlays // {
        pkgs = final: prev: import ./pkgs/top-level/all-packages.nix { pkgs = prev; };
      };

      overlay = final: prev: {
        xeals = nixpkgs.lib.composeExtensions self.overlays.pkgs;
      };
    } // eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        xPkgs = import ./pkgs/top-level/all-packages.nix { inherit pkgs; };
        mkApp = opts: { type = "app"; } // opts;
      in
      rec {
        packages = filterAttrs
          (attr: drv: builtins.elem system (drv.meta.platforms or [ ]))
          (flattenTree xPkgs);

        apps = flattenTree {
          alacritty = mkApp { program = "${packages.alacritty-ligatures}/bin/alacritty"; };
          protonmail-bridge = mkApp { program = "${packages.protonmail-bridge}/bin/protonmail-bridge"; };
          protonmail-bridge-headless = mkApp { program = "${packages.protonmail-bridge}/bin/protonmail-bridge"; };
          psst = {
            cli = mkApp { program = "${packages.psst}/bin/psst-cli"; };
            gui = mkApp { program = "${packages.psst}/bin/psst-gui"; };
          };
          samrewritten = mkApp { program = "${packages.samrewritten}/bin/samrewritten"; };
          spotify-ripper = mkApp { program = "${packages.spotify-ripper}/bin/spotify-ripper"; };
        };
      });
}
