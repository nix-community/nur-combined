{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        importPkgs = p: import p {
          inherit system;
          config = { allowUnfree = true; };
        };
        pkgs = importPkgs nixpkgs;
        inherit (pkgs) lib;

        sources = import ./pkgs/sources.nix {
          inherit (pkgs) fetchgit fetchurl;
        };
        packages = import ./pkgs {
          inherit pkgs sources;
        };
        platformFilter = sys: p:
          if p.meta ? platforms
          then pkgs.lib.elem sys p.meta.platforms
          else true;
        filteredPackages = pkgs.lib.filterAttrs (_: platformFilter system) packages;

        mkApp = drvName: cfg:
          if self.packages.${system} ? ${drvName}
          then {
            "${drvName}" = flake-utils.lib.mkApp ({ drv = self.packages.${system}.${drvName}; } // cfg);
          }
          else { };
      in
      {
        inherit sources;
        packages = filteredPackages;
        apps =
          mkApp "updater" { } //
          mkApp "activate-dpt" { } //
          mkApp "clash-for-windows" { name = "cfw"; } //
          mkApp "clash-premium" { } //
          mkApp "dpt-rp1-py" { name = "dptrp1"; } //
          mkApp "godns" { } //
          mkApp "trojan" { } //
          mkApp "vlmcsd" { };

        checks = flake-utils.lib.flattenTree {
          packages = pkgs.lib.recurseIntoAttrs self.packages.${system};
        };
        devShell =
          let
            simple = pkgs.mkShell {
              packages = [
                pkgs.nixpkgs-fmt
              ];
            };
            withUpdater = pkgs.mkShell {
              inputsFrom = [
                simple
                self.packages.${system}.updater.env
              ];
              packages = [
                pkgs.cabal-install
                pkgs.ormolu
                (pkgs.writeScriptBin "update" ''
                  nix shell .#updater --command bash -c '
                    cd pkgs
                    echo "$PWD"
                    updater
                  '
                  nixpkgs-fmt .
                '')
                pkgs.nix-linter
                pkgs.fd
                (pkgs.writeScriptBin "lint" ''
                  fd '.*\.nix' --exec nix-linter
                '')
              ];
            };
          in
          if (self.packages.${system} ? updater) then withUpdater else simple;
      })) //
    {
      lib = import ./lib { inherit (nixpkgs) lib; };
      nixosModules = import ./modules;
      overlays = {
        linyinfeng = final: _prev: {
          linyinfeng = self.packages.${final.system};
        };
      } // import ./overlays;
    };
}
