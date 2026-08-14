{
  pkgs,
  lib,
  callPackage,
  bzip2,
  expat,
  libffi,
  gdbm,
  db,
  ncurses,
  openssl,
  readline,
  sqlite,
  tcl ? null,
  tk ? null,
  tclPackages,
  libx11 ? null,
  x11Support ? false,
  zlib,
  coreutils,
  ucsEncoding ? 4,
}:

let
  python-setup-hook =
    sitePackages:
    pkgs.replaceVars ./setup-hook.sh {
      inherit sitePackages;
    };

  args = {
    inherit
      bzip2
      expat
      libffi
      gdbm
      db
      ncurses
      openssl
      readline
      sqlite
      tcl
      tk
      tclPackages
      libx11
      x11Support
      zlib
      coreutils
      ucsEncoding
      python-setup-hook
      ;
    passthruFun = passthru: passthru;
    sourceVersion = {
      major = "2";
      minor = "7";
      patch = "18";
      suffix = "";
    };
    hash = "sha256-NtDJrVmGgKrb2okcl42+La6t/aj4S2WuuktJ8VavH2s=";
  };
in
lib.fix (self: callPackage ./default.nix (args // { inherit self; }))
