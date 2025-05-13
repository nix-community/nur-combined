{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.ciSubsetName = {
    url = "file+file:///dev/null";
    flake = false;
  };
  inputs.ciCachedBuildFailures = {
    url = "file+file:///dev/null";
    flake = false;
  };
  # Disabled for now to get rid of the warning - just add the cache manually
  # nixConfig = {
  #   extra-substituters = ["https://rhys-t.cachix.org"];
  #   extra-trusted-public-keys = ["rhys-t.cachix.org-1:u01ifDlaQjvJbtMT1Saw+oaFX1Lf/Urw+ND0i/L4kgw="];
  # };
  outputs = { self, nixpkgs, ciSubsetName, ciCachedBuildFailures }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      } // {
        ci = let
          subsetName = nixpkgs.lib.pipe ciSubsetName.outPath [
            (x: if nixpkgs.lib.pathIsDirectory x then x+"/ciSubsetName" else x)
            (builtins.readFile)
            (x: if x == "" then "all" else x)
          ];
          cachedBuildFailures' = ciCachedBuildFailures.outPath;
          cachedBuildFailures = if nixpkgs.lib.pathIsDirectory cachedBuildFailures' then cachedBuildFailures' else null;
          ci = import ./ci.nix {
            pkgs = import nixpkgs {
              inherit system;
            };
            inherit subsetName cachedBuildFailures;
          };
        in ci;
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
      apps = forAllSystems (system: nixpkgs.lib.concatMapAttrs (name: value: (value._Rhys-T.flakeApps or (name: value: {})) name value) self.packages.${system});
    };
}
