{ pkgs }:

let

  inherit (pkgs) lib;
  inherit (lib) optionalAttrs versionAtLeast;
  pkgsVersion = lib.versions.majorMinor lib.version;

  hmSrc = import ./src.nix { lib = pkgs.lib; };

  hm = import "${hmSrc}" { inherit pkgs; };

in optionalAttrs (versionAtLeast pkgsVersion "20.09") {
  htmlManual = hm.docs.html;
  jsonOptions = hm.docs.json;
  manPages = hm.docs.manPages;
}
