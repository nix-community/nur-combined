{ sources ? import ../../nix
, lib ? sources.lib
, pkgs ? sources.nixpkgs { }
}:

with pkgs;
let avrlibc = pkgsCross.avr.libcCross; in
rec {
  qmkSource = fetchgit {
    url = "https://github.com/qmk/qmk_firmware";
    rev = "0.10.50";
    sha256 = "162rvhqyx25fz39395vhhk3allbfn4bd8c1afj8ip9r27zwnqrwd";
    fetchSubmodules = true;
  };

  layout = stdenv.mkDerivation rec {
    name = "ergodox_ez_sbr.hex";

    src = qmkSource;

    buildInputs = [
      dfu-programmer
      dfu-util
      diffutils
      git
      python3
      pkgsCross.avr.buildPackages.binutils
      pkgsCross.avr.buildPackages.gcc8
      avrlibc
      avrdude
    ];

    AVR_CFLAGS = [
      "-isystem ${avrlibc}/avr/include"
      "-L${avrlibc}/avr/lib/avr5"
    ];

    AVR_ASFLAGS = AVR_CFLAGS;

    patches = [ ./increase-tapping-delay.patch ];

    postPatch = ''
      mkdir keyboards/ergodox_ez/keymaps/sbr
      cp ${./keymap.c} keyboards/ergodox_ez/keymaps/sbr/keymap.c
      cp ${./config.h} keyboards/ergodox_ez/keymaps/sbr/config.h
      cp ${./rules.mk} keyboards/ergodox_ez/keymaps/sbr/rules.mk
    '';

    buildPhase = ''
      make ergodox_ez:sbr
    '';

    installPhase = ''
      cp ergodox_ez_sbr.hex $out
    '';
  };

  flash = writeShellScript "flash.sh" ''
    ${teensy-loader-cli}/bin/teensy-loader-cli \
      -v \
      --mcu=atmega32u4 \
      -w ${layout}
  '';

  meta.targets = [ "layout" ];
}
