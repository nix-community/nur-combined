{
  description = "UlyssesZhan's personal Nix package set";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems =
        f:
        builtins.foldl' (attrs: system: attrs // { ${system} = f (self.call { inherit system; }); }) { } (
          import ./all-systems.nix
        );
    in
    {
      call = args: import ./. (args // (if args ? nixpkgs then { } else { inherit nixpkgs; }));

      packages = forAllSystems (pkgs: pkgs.ulypkgsPackagesDerivationsOnly);

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);

      overlays.default = import ./pkgs;
    };
}
