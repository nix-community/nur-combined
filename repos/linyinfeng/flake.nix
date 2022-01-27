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

        lib = import ./lib { inherit (nixpkgs) lib; };
        nixosModules = import ./modules;
        overlays = import ./overlays // {
          linyinfeng = final: prev: { linyinfeng = makePackages ./pkgs { pkgs = prev; }; };
          linyinfengWithIfd = final: prev: { linyinfeng = makePackages ./pkgs { pkgs = prev; withIfd = true; }; };
          singleRepoNur = final: prev: {
            nur = prev.lib.recursiveUpdate (prev.nur or { }) {
              repos.linyinfeng = makePackages ./pkgs { pkgs = prev; };
            };
          };
          singleRepoNurWithIfd = final: prev: {
            nur = prev.lib.recursiveUpdate (prev.nur or { }) {
              repos.linyinfeng = makePackages ./pkgs { pkgs = prev; withIfd = true; };
            };
          };
        };

        channels.nixpkgs.config = {
          allowUnfree = true;
          allowAliases = false;
        };

        outputsBuilder = channels:
          let
            pkgs = channels.nixpkgs;
          in
          rec {
            packages = utils.flattenTree (makePackages ./pkgs { inherit pkgs; });
            apps = makeApps packages appNames;
            packagesWithIfd = utils.flattenTree (makePackages ./pkgs { inherit pkgs; withIfd = true; });
            appsWithIfd = makeApps packagesWithIfd appNames;
            devShell =
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
      };
}
