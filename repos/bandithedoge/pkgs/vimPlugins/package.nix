{
  callPackage',

  pkgs,
  lib,
  vimUtils,
}:
let
  sources = import ./npins { };
in
(lib.makeExtensible (
  _:
  lib.attrsets.mapAttrs' (
    name: src':
    let
      src = src' { inherit pkgs; };
    in
    lib.attrsets.nameValuePair
      (builtins.replaceStrings [ "." ] [ "-" ] (lib.strings.sanitizeDerivationName name))
      (
        vimUtils.buildVimPlugin {
          pname = name;
          version = src.revision;
          inherit src;
          doCheck = false;
        }
      )
  ) sources
)).extend
  (callPackage' ./_overrides.nix { })
