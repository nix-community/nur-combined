{
  description = "xeals's Nix repository";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    let
      inherit (nixpkgs) lib;
      inherit (flake-utils.lib) mkApp;
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          packages =
            lib.filterAttrs
              (_: drv: builtins.elem system (drv.meta.platforms or [ ]))
              (import ./pkgs/top-level/all-packages.nix { inherit pkgs; });

          checks = {
            nixpkgs-fmt = pkgs.writeShellScriptBin "nixpkgs-fmt-check" ''
              ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check .
            '';
            deadnix = pkgs.writeShellScriptBin "deadnix-check" ''
              ${pkgs.deadnix}/bin/deadnix --fail .
            '';
          };

          devShells.ci = pkgs.mkShellNoCC {
            buildInputs = [ pkgs.nix-build-uncached ];
          };

          apps = {
            alacritty = mkApp { drv = pkgs.alacritty-ligatures; exePath = "/bin/alacritty"; };
            protonmail-bridge = mkApp { drv = pkgs.protonmail-bridge; };
            protonmail-bridge-headless = mkApp { drv = pkgs.protonmail-bridge; };
            psst-cli = mkApp { drv = pkgs.psst; exePath = "/bin/psst-cli"; };
            psst-gui = mkApp { drv = pkgs.psst; exePath = "/bin/psst-gui"; };
            samrewritten = mkApp { drv = pkgs.samrewritten; };
            spotify-ripper = mkApp { drv = pkgs.spotify-ripper; };
          };
        })
    // {
      nixosModules = lib.mapAttrs (_: path: import path) (import ./modules) // {
        default = {
          imports = lib.attrValues self.nixosModules;
        };
      };

      overlays = import ./overlays // {
        pkgs = _: prev: import ./pkgs/top-level/all-packages.nix { pkgs = prev; };
        default = _: _: { xeals = nixpkgs.lib.composeExtensions self.overlays.pkgs; };
      };
    };
}
