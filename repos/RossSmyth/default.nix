{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) callPackage;
in
pkgs.lib.fix (self: {
  jqjq = callPackage ./jqjq { };
  isle-portable = callPackage ./isle-portable { };
  cerberus = callPackage ./cerberus { };
  wuffs = callPackage ./wuffs { };

  # MSVC stuff
  fetchMsvcSdk = callPackage ./msvc-sdk/fetchMsvcSdk.nix { };
  msvcSdk = callPackage ./msvc-sdk/msvc-sdk.nix { inherit (self) fetchMsvcSdk; };
})
