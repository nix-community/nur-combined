{
  description = "xeals's Nix repository";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          legacyPackages = import ./default.nix {
            inherit pkgs;
          };

          packages = nixpkgs.lib.filterAttrs (_: nixpkgs.lib.isDerivation) self.legacyPackages.${system};

          formatter = pkgs.writeShellScriptBin "nur-packages-fmt" ''
            ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt .
            ${pkgs.deadnix}/bin/deadnix -e .
          '';

          checks = {
            # Ensures that the NUR bot can evaluate and find all our packages.
            # Normally we'd also run with `--option restrict-eval true`, but
            # this is incompatible with flakes because reasons.
            nur = pkgs.writeShellScriptBin "nur-check" ''
              # Prefer nixpkgs channel (actual build), otherwise read from flake.lock (CI)
              if ! nixpkgs=$(nix-instantiate --find-file nixpkgs 2>/dev/null); then
                _rev=$(${pkgs.jq}/bin/jq -r .nodes.nixpkgs.locked.rev flake.lock)
                nixpkgs="https://github.com/nixos/nixpkgs/archive/''${_rev}.tar.gz"
              fi
              nix-env -f . -qa \* --meta \
                --allowed-uris https://static.rust-lang.org \
                --option allow-import-from-derivation true \
                --drv-path --show-trace \
                -I nixpkgs="$nixpkgs" \
                -I ./ \
                --json | ${pkgs.jq}/bin/jq -r 'values | .[].name'
            '';
          };

          devShells.ci = pkgs.mkShellNoCC {
            buildInputs = [ pkgs.nix-build-uncached ];
          };
        })
    // {
      nixosModules = import ./modules // {
        default = { ... }: { imports = nixpkgs.lib.attrValues self.nixosModules; };
      };
      overlays = import ./overlays;
    };
}
