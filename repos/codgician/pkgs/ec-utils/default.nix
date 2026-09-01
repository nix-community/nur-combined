{
  lib,
  stdenv,
  fetchgit,
  fetchFromGitHub,
  bash,
  clang,
  makeWrapper,
  coreutils,
  gawk,
  gnugrep,
  gnused,
  lsof,
  ncurses,
  procps,
  util-linux,
  which,
}:

let
  version = "unstable-2026-08-31";

  shflags = fetchFromGitHub {
    owner = "kward";
    repo = "shflags";
    rev = "60d96bba87965bb3cf50653ca1544580b01f5de3";
    hash = "sha256-OEYSjEOCK6Uu8K2A3KJ+ocIXUlAWDTVi9QO4hpAMbkM=";
  };
in
stdenv.mkDerivation {
  pname = "ec-utils";
  inherit version;

  src = fetchgit {
    url = "https://chromium.googlesource.com/chromiumos/platform/ec";
    rev = "5c23fe0d7a6567aadd82befe9213df6a75d4f55d";
    hash = "sha256-w4cItrDawsrqha+HkCcgH+BIZBdoF9B3CwtC3FJCj6U=";
  };

  strictDeps = true;
  nativeBuildInputs = [
    bash
    clang
    makeWrapper
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    clang++ -O2 -Wall -Wextra -std=c++17 \
      -Iinclude -Iutil \
      util/uut/main.cc \
      util/uut/cmd.cc \
      util/uut/opr.cc \
      util/uut/l_com_port.cc \
      util/uut/lib_crc.cc \
      -o uartupdatetool

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 uartupdatetool "$out/bin/uartupdatetool"
    install -Dm755 util/flash_ec "$out/libexec/chromeos-ec/flash_ec"
    substituteInPlace "$out/libexec/chromeos-ec/flash_ec" \
      --replace-fail '#!/bin/bash' '#!${lib.getExe bash}' \
      --replace-fail '/usr/share/misc/shflags' '${shflags}/shflags'

    makeWrapper "$out/libexec/chromeos-ec/flash_ec" "$out/bin/flash_ec" \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          gawk
          gnugrep
          gnused
          lsof
          ncurses
          procps
          util-linux
          which
        ]
      }

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    "$out/bin/uartupdatetool" --help >/dev/null
    help_output=$("$out/bin/flash_ec" --help 2>&1 || true)
    grep -Fq -- '--offset' <<<"$help_output"

    runHook postInstallCheck
  '';

  meta = {
    description = "Host-side tools for flashing and debugging ChromeOS embedded controllers";
    homepage = "https://chromium.googlesource.com/chromiumos/platform/ec/";
    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ codgician ];
  };
}
