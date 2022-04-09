{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };

  outputs = { self, nixpkgs, flake-utils-plus }@inputs:
    let
      utils = flake-utils-plus.lib;
      inherit (nixpkgs) lib;
      inherit (self.lib) makePackages makeApps appNames;
    in
    utils.mkFlake
      {
        inherit self inputs;

        sharedOverlays = builtins.attrValues (self.overlays);
        channels.nixpkgs.config = {
          allowUnfree = true;
          allowAliases = false;
        };

        outputsBuilder = channels:
          let
            pkgs = channels.nixpkgs;
          in
          rec {
            packages = utils.flattenTree (makePackages pkgs);
            apps = makeApps packages appNames;
            devShells.default =
              let
                scripts = pkgs.callPackage ./scripts { };
                simple = pkgs.mkShell {
                  packages = [
                    # currently nothing
                  ];
                };
                withUpdater = pkgs.mkShell {
                  inputsFrom = [
                    simple
                    packages.updater.env
                  ];
                  packages = [
                    pkgs.nixpkgs-fmt
                    pkgs.cabal-install
                    pkgs.ormolu
                  ] ++ (with scripts; [
                    update
                    lint
                  ]);
                };
              in
              if (packages ? updater) then withUpdater else simple;
            checks = packages;
          };

        overlays = import ./overlays // {
          linyinfeng = final: prev: {
            linyinfeng = makePackages prev;
          };
          singleRepoNur = final: prev: {
            nur = prev.lib.recursiveUpdate (prev.nur or { }) {
              repos.linyinfeng = makePackages prev;
            };
          };
        };


        lib = import ./lib { inherit (nixpkgs) lib; };
        nixosModules = import ./modules;
      };
}
