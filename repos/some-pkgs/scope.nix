# FIXME: This is one huge pile of mess that hasn't been maintained since, about, early 2024.

{
  lib,
  newScope,
  recurseIntoAttrs,
  withSomePkgsPy ? null,
}:

lib.makeScope newScope (
  self:
  let
    python3Packages = lib.removeAttrs (self.callPackage ({ python3Packages }: python3Packages) { }) [
      "override"
      "callPackage"
    ];
    some-pkgs-py =
      if withSomePkgsPy != null then
        withSomePkgsPy
      else
        (self.callPackage ./pythonScope.nix {
          newScope = next: python3Packages.newScope (self // next);
          withSomePkgs = self;
        });
  in
  lib.autocallByName self.callPackage ./pkgs/by-name
  // {
    some-pkgs = self;
    some-pkgs-py = recurseIntoAttrs some-pkgs-py;
    some-util = recurseIntoAttrs (self.callPackage ./some-util { });
    some-datasets = recurseIntoAttrs (
      self.callPackage ./datasets {
        inherit lib;
      }
    );
    faiss = self.callPackage ./pkgs/by-name/fa/faiss { };
  }
)
