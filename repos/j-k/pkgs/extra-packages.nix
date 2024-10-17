{ pkgs }:

let
  inherit (pkgs) callPackage;
in
rec {
  # for if a package requires specific args to be replaced
  # somepackage = pkgs.callPackage ./by-name/so/somepackage/package.nix {
  #   something = "hi";
  # };

  # dev utils
  fetchDenoTarball = callPackage ./extra/fetchDenoTarball.nix { };
  bundleDeno = callPackage ./extra/bundleDeno.nix { inherit fetchDenoTarball; };
}
