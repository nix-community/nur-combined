{
  pkgs ? import <nixpkgs> { },
  isFlake ? false,
}:

let
  inherit (pkgs) lib;

  result = lib.filesystem.packagesFromDirectoryRecursive {
    callPackage = pkgs.callPackage;
    directory = ./pkgs;
  };
in

builtins.removeAttrs
  (
    result
    // {
      blender-bin = lib.recurseIntoAttrs result.blender-bin;
    }
    // lib.optionalAttrs isFlake result.blender-bin
  )
  (
    [
      "override"
      "overrideAttrs"
      "overrideDerivation"
    ]
    ++ lib.optionals isFlake [ "blender-bin" ]
  )
