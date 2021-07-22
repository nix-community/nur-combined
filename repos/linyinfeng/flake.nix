{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
        mkApp = drvName: cfg: flake-utils.lib.mkApp ({ drv = self.packages.${system}.${drvName}; } // cfg);
      in
      rec {
        packages = import ./pkgs { inherit pkgs; } // {
          updater = pkgs.callPackage ./pkgs/updater { };
        };
        apps = {
          updater = mkApp "updater" { };
          activate-dpt = mkApp "activate-dpt" { };
          clash-premium = mkApp "clash-premium" { };
          dpt-rp1-py = mkApp "dpt-rp1-py" { name = "dptrp1"; };
          godns = mkApp "godns" { };
          trojan = mkApp "trojan" { };
          vlmcsd = mkApp "vlmcsd" { };
        };
        checks = flake-utils.lib.flattenTree {
          packages = pkgs.lib.recurseIntoAttrs self.packages.${system};
        };
        devShell = pkgs.mkShell {
          inputsFrom = [
            packages.updater.env
          ];
          packages = [
            pkgs.cabal-install
            pkgs.ormolu
            (pkgs.writeScriptBin "update" ''
              ${packages.updater}/bin/updater "$@"
            '')
          ];
        };
      })) //
    {
      lib = import ./lib { inherit (nixpkgs) lib; };
      nixosModules = import ./modules;
      overlays = {
        singleRepoNur = final: prev: {
          nur.repos.linyinfeng = self.packages.${final.system};
        };
      } // import ./overlays;
    };
}
