{
  description = "My personal NUR repository";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      inherit (nixpkgs) lib;
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          packages =
            let
              legacyPackages = import ./pkgs/top-level/all-packages.nix { inherit pkgs; };
              onlyAvailable = lib.filterAttrs (_: drv: builtins.elem system (drv.meta.platforms or [ ]));
            in
            onlyAvailable (legacyPackages);

          checks = {
            fmt = pkgs.writeShellScriptBin "fmt-check" ''
              ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check .
            '';
            dead = pkgs.writeShellScriptBin "dead-check" ''
              ${pkgs.deadnix}/bin/deadnix --fail .
            '';
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
        })
    // {
      nixosModules = lib.mapAttrs (_: path: import path) (import ./modules) // {
        default = {
          imports = lib.attrValues self.nixosModules;
        };
      };

      overlays = import ./overlays // {
        pkgs = _: prev: import ./pkgs/top-level/all-packages.nix { pkgs = prev; };
        default = _: _: { unmagical = nixpkgs.lib.composeExtensions self.overlays.pkgs; };
      };
    };
}
