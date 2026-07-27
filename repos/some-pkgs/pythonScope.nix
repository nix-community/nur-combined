# FIXME: This is one huge pile of mess that hasn't been maintained since, about, early 2024.

{
  lib,
  newScope,
  withSomePkgs ? null,
}:

lib.makeScope newScope (
  self:
  let
    some-pkgs =
      if withSomePkgs != null then
        withSomePkgs
      else
        (self.callPackage ./scope.nix { withSomePkgsPy = self; });

    # FIXME: Recover splicing (python3Packages) once https://github.com/NixOS/nixpkgs/pull/394838 is fixed
    python3Packages = self.callPackage ({ python }: python.pkgs) { };

  in
  lib.autocallByName self.callPackage ./python-packages/by-name
  // {
    inherit some-pkgs;
    cppcolormap = self.callPackage (
      { toPythonModule, some-pkgs }:
      some-pkgs.cppcolormap.override {
        enablePython = true;
        inherit python3Packages;
      }
    ) { };

    some-pkgs-faiss = self.callPackage (
      { toPythonModule }:
      toPythonModule (
        some-pkgs.faiss.override {
          pythonSupport = true;
          inherit python3Packages;
        }
      )
    ) { };

    instant-ngp = self.callPackage ./python-packages/by-name/in/instant-ngp/package.nix { };

    quad-tree-loftr = self.quad-tree-attention.feature-matching;
  }
)
