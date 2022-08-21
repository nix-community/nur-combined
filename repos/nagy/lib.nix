{ pkgs, lib ? pkgs.lib, ... }:

with builtins;
with lib; rec {
  gltf-pipeline = let
    mypkgs = import (pkgs.fetchFromGitHub {
      owner = "nagy";
      repo = "nixpkgs";
      rev = "946704823d74346749656fb80c208716cf600c02";
      hash = "sha256-AY1AFFOirNQS6VM6DXit50mPpzwH6zefNJOIB41JKCA=";
    }) { };
  in mypkgs.nodePackages.gltf-pipeline;

  mkGlb2Gltf = src:
    let
      thename =
        replaceStrings [ ".glb" ] [ ".gltf" ] (toString (baseNameOf src));
    in pkgs.runCommand thename {
      nativeBuildInputs = [ gltf-pipeline ];
      inherit src;
    } ''
      gltf-pipeline --input $src --output $out
    '';

  mkAvrdudeFlasher = { name, hex }@args:
    pkgs.writeShellScriptBin "${name}-flasher" ''
      exec ${pkgs.avrdude}/bin/avrdude -p atmega32u4 -c avr109 -P /dev/ttyACM0 -U flash:w:${hex}:i
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

        passthru.flasher = mkAvrdudeFlasher { inherit (self) name hex; };

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
