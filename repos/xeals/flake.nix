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
          # nixos/rfcs#140
          # Only produces the package set of the proposed functionality.
          # Unstable names are variables.
          packages =
            let
              legacyPackages = import ./pkgs/top-level/all-packages.nix { inherit pkgs; };
              unitPackages = import ./callUnitRoot.nix { inherit pkgs; };
              onlyAvailable = lib.filterAttrs (_: drv: builtins.elem system (drv.meta.platforms or [ ]));
            in
            onlyAvailable (legacyPackages // unitPackages);

          checks = {
            nixpkgs-fmt = pkgs.writeShellScriptBin "nixpkgs-fmt-check" ''
              ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check .
            '';
            deadnix = pkgs.writeShellScriptBin "deadnix-check" ''
              ${pkgs.deadnix}/bin/deadnix --fail .
            '';
            # Ensures that the NUR bot can evaluate and find all our packages.
            # Normally we'd also run with `--option restrict-eval true`, but
            # this is incompatible with flakes because reasons.
            nur = pkgs.writeShellScriptBin "nur-check" ''
              nix-env -f . -qa \* --meta \
                --allowed-uris https://static.rust-lang.org \
                --option allow-import-from-derivation true \
                --drv-path --show-trace \
                -I nixpkgs=$(nix-instantiate --find-file nixpkgs) \
                -I ./ \
                --json | ${pkgs.jq}/bin/jq -r 'values | .[].name'
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
