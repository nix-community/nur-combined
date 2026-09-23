{
  description = "UlyssesZhan's personal Nix package set";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      forAllSystems =
        f:
        builtins.foldl' (attrs: system: attrs // { ${system} = f (self.call { inherit system; }); }) { } (
          import ./all-systems.nix
        );
    in
    {
      call = args: import ./. (args // (if args ? nixpkgs then { } else { inherit nixpkgs; }));

      # packages that upstream only provides for some platforms have nothing to
      # build on the other platforms, so they are not exposed there
      packages = forAllSystems (
        pkgs:
        lib.filterAttrs (
          name: package: lib.meta.availableOn pkgs.stdenv.hostPlatform package
        ) pkgs.ulypkgsPackagesDerivationsOnly
      );

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);

      overlays.default = import ./pkgs;
    };
}
