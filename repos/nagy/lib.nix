{ pkgs, lib, callPackage, fetchFromGitHub }:

with builtins;
with lib; rec {
  mkAvrdudeFlasher = firmware:
    pkgs.writeShellScriptBin "${firmware.name}-flasher" ''
      exec ${pkgs.avrdude}/bin/avrdude \
        -p atmega32u4 \
        -c avr109 \
        -P /dev/ttyACM0 \
        -U flash:w:${firmware.hex}:i "$@"
    '';

  mkQmkFirmware = { name, keymap ? "default", ... }@args:
    pkgs.stdenv.mkDerivation ((finalAttrs:
      {
        inherit keymap;
        src = pkgs.fetchFromGitHub {
          owner = "qmk";
          repo = "qmk_firmware";
          rev = "0.16.9";
          sha256 = "sha256-gnQ/hehxPiYujakJWZynAJ7plJiDciAG3NAy0Xl18/A=";
          fetchSubmodules = true;
        };

        nativeBuildInputs = [ pkgs.qmk ];

        # this allows us to not need the .git folder
        SKIP_VERSION = "1";

        outputs = [ "out" "hex" ];

        passthru.flasher = mkAvrdudeFlasher finalAttrs.finalPackage;

        makeFlags = [ "$(keyboard):default" ];

        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/qmk
          install -Dm444 *.hex $hex
          ln -s $hex $out/share/qmk/${name}.hex
          runHook postInstall
        '';
      } // args));

}
