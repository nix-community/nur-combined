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
  xwin = callPackage ./xwin { };
  msvcSdk = callPackage ./msvc-sdk { inherit (self) xwin; };
  clang-cl = callPackage ./clang-cl {
    inherit (self) msvcSdk;
  };
  msvcRust = callPackage ./msvc-rust {
    inherit (self) clang-cl msvcSdk;
    rustc =
      pkgs.rust-bin.stable.latest.minimal.override
        or (throw "requires rust-overlay to get windows-msvc std")
        { targets = [ "x86_64-pc-windows-msvc" ]; };
  };
})
