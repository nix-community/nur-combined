{
  lib,
  stdenv,
  fetchurl,
  m4,
  zlib,
  bzip2,
  bison,
  flex,
  gettext,
  xz,
  setupDebugInfoDirs,
  pkg-config,
  libarchive,
  curl,
  sqlite,
  libmicrohttpd,
  elfutils,
} @ args: let
  args_ = builtins.removeAttrs args ["elfutils"];

  #elfutils_0_179 = lib.upgradeOverride (elfutils.override args_) (oldAttrs: rec {
  elfutils_0_179 = lib.upgradeOverride elfutils (oldAttrs:
    with oldAttrs; rec {
      version = "0.179";
      src = fetchurl {
        url = "https://sourceware.org/elfutils/ftp/${version}/${pname}-${version}.tar.bz2";
        sha256 = "sha256-JaVFVmy6yqN65iIuWPHEjqRXD1O6mRiG4vXOluIqI6I=";
      };
      buildInputs = oldAttrs.buildInputs ++ [pkg-config libarchive curl sqlite libmicrohttpd];
    });

  self = {
    inherit elfutils_0_179;
  };
in
  self
