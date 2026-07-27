{
  callPackage',

  pkgs,
  lib,

  emacsPackages,
  writeText,
}:
let
  sources = import ./npins { };
in
(lib.makeExtensible (
  _:
  lib.attrsets.mapAttrs' (
    name: src':
    let
      sanitizedName = lib.pipe name [
        (lib.removeSuffix ".el")
        (builtins.replaceStrings [ "." ] [ "-" ])
        lib.strings.sanitizeDerivationName
      ];
      src = src' { inherit pkgs; };
    in
    lib.attrsets.nameValuePair sanitizedName (
      emacsPackages.melpaBuild {
        pname = sanitizedName;
        # TODO: set version properly
        # https://github.com/nmattia/niv/issues/111
        version = "0";
        inherit src;
        commit = src.revision;

        recipe = writeText "recipe" ''
          (${sanitizedName}
            :repo "${src.repository.owner}/${src.repository.repo}"
            :fetcher github)
        '';
      }
    )
  ) sources
)).extend
  (callPackage' ./_overrides.nix { })
