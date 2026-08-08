{ pkgs, lib, stdenv, callPackage, fetchFromGitHub, fetchpatch, bzip2, expat, libffi, gdbm, db, ncurses, openssl, readline, sqlite, tcl ? null, tk ? null, tclPackages, libx11 ? null, x11Support ? false, zlib, coreutils, ucsEncoding ? 4, config }:

let
  python-setup-hook = sitePackages: pkgs.replaceVars ./setup-hook.sh {
    inherit sitePackages;
  };
in callPackage ./default.nix {
  inherit bzip2 expat libffi gdbm db ncurses openssl readline sqlite tcl tk tclPackages libx11 x11Support zlib coreutils ucsEncoding python-setup-hook;
  self = callPackage ./default.nix {};
  passthruFun = attrs: attrs;
  sourceVersion = {
    major = "2";
    minor = "7";
    patch = "18";
    suffix = "";
  };
  hash = "sha256-NtDJrVmGgKrb2okcl42+La6t/aj4S2WuuktJ8VavH2s="; # updated sri hash for ActiveState cpython 2.7.18
}
