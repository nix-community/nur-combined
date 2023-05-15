{ pkgs, ... }:

rec {
  mkAvrdudeFlasher = firmware:
    pkgs.writeShellScriptBin "${firmware.name}-flasher" ''
      exec ${pkgs.avrdude}/bin/avrdude \
        -p atmega32u4 \
        -c avr109 \
        -P /dev/ttyACM0 \
        -U flash:w:${firmware}:i "$@"
    '';

  mkQmkFirmware = { name, keyboard, keymap ? "default", ... }@args:
    pkgs.stdenv.mkDerivation (finalAttrs:
      {
        inherit keyboard keymap;
        src = pkgs.fetchFromGitHub {
          owner = "qmk";
          repo = "qmk_firmware";
          rev = "0.20.7";
          sha256 = "sha256-S6EuLiMbJp7sgAVGV0M9DuinuVLwQ9hStjlA5w9VxOo=";
          fetchSubmodules = true;
        };

        nativeBuildInputs = [ pkgs.qmk ];

        # this allows us to not need the .git folder
        SKIP_VERSION = "1";

        outputs = [ "out" "hex" ];

        passthru.flasher = mkAvrdudeFlasher finalAttrs.finalPackage.hex;

        makeFlags = [ "$(keyboard):default" ];

        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/qmk
          install -Dm444 *.hex $hex
          ln -s $hex $out/share/qmk/${name}.hex
          runHook postInstall
        '';

        preferLocalBuild = true;
        allowSubstitutes = false;
      } // args);

}
