{ pkgs, lib ? pkgs.lib }:

with builtins;
with lib; rec {
  gltf-pipeline = pkgs.callPackage (pkgs.fetchFromGitHub {
    githubBase = "gist.github.com";
    owner = "nagy";
    repo = "053eb914dcbf8270e6d6c1f304ce236e";
    rev = "master";
    hash = "sha256-SC5sw3KwCHpc0Or09zLSr6UfrghVGetX9V03/VPbqmo=";
  }) { };

  mkGlb2Gltf = src:
    let
      name = replaceStrings [ ".glb" ] [ ".gltf" ] (toString (baseNameOf src));
    in pkgs.runCommand name { inherit src; } ''
      ${getExe gltf-pipeline} --input $src --output $out
    '';

  mkAvrdudeFlasher = firmware:
    pkgs.writeShellScriptBin "${firmware.name}-flasher" ''
      exec ${pkgs.avrdude}/bin/avrdude -p atmega32u4 -c avr109 -P /dev/ttyACM0 -U flash:w:${firmware.hex}:i
    '';

  mkQmkFirmware = { name, keyboard, keymap ? "default", ... }@args:
    let
      self = pkgs.stdenv.mkDerivation (args // {
        inherit keymap;
        # may later be replaced with pkgs.qmk-udev-rules
        # no, because fetchSubmodules
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

        passthru.flasher = mkAvrdudeFlasher self;

        buildPhase = ''
          runHook preBuild
          make --jobs=1 $keyboard:default
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/qmk
          install -Dm444 *.hex $hex
          ln -s $hex $out/share/qmk/${name}.hex
          runHook postInstall
        '';
      });
    in self;
}
