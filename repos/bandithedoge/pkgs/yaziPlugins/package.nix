{
  callPackage',

  pkgs,
  lib,

  stdenvNoCC,
}:
let
  sources = import ./npins { };
in
(lib.makeExtensible (
  _:
  lib.mapAttrs' (
    name: src':
    let
      src = src' { inherit pkgs; };
    in
    lib.nameValuePair (lib.removeSuffix ".yazi" name) (
      stdenvNoCC.mkDerivation {
        pname = name;
        version = src.revision;
        inherit src;
        buildPhase = ''
          runHook preBuild

          cp -r ${src} $out

          runHook postBuild
        '';
      }
    )
  ) sources
)).extend
  (callPackage' ./_overrides.nix { })
