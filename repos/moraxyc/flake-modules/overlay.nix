{
  self,
  inputs,
  ...
}:
{
  flake = {
    overlay = self.overlays.default;
    overlays.default =
      _final: prev:
      let
        inherit (prev) lib;
        filters = import ../helpers/filters.nix {
          inherit lib;
          inherit (prev) stdenv;
        };
        sources = (import ../lib/sources-overlay.nix { inherit lib; }) prev prev;
        nurScope = lib.fix (
          nurSelf:
          let
            nurCallPackage = lib.callPackageWith (
              prev
              // {
                inherit inputs;
                nur-moraxyc = self;
                nixpkgs = prev;
              }
              // sources
              // nurSelf
              // {
                callPackage = nurCallPackage;
              }
            );
          in
          lib.concatMapAttrs (_: v: v) (
            lib.packagesFromDirectoryRecursive {
              callPackage = nurCallPackage;
              directory = ../pkgs/by-name;
            }
          )
        );
      in
      lib.filterAttrs (n: _: filters.isOverlayName n) nurScope;
  };
}
