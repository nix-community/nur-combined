{
  pkgs ? import <nixpkgs> {
    overlays = [
      (import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"))
    ];
  },
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
  clang-cl = callPackage ./clang-cl {
    inherit (self) fetchMsvcSdk msvcSdk;
  };
  msvc-rustc = callPackage ./msvc-rust {
    inherit (self) fetchMsvcSdk msvcSdk clang-cl;
    rustc =
      pkgs.rust-bin.stable.latest.minimal.override
        or (throw "requires rust-overlay to get windows-msvc std")
        {
          targets = [ "x86_64-pc-windows-msvc" ];
        };
  };
})
