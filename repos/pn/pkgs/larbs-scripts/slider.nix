{ stdenv, callPackage, buildEnv, lowPrio, ffmpeg, imagemagick }:
let
  voidrice = callPackage ../voidrice.nix { };
in
  buildEnv {
    name = "slider";
    paths = [
      (lowPrio ffmpeg)
      (lowPrio imagemagick)
    ];
    postBuild = ''
      cp  ${voidrice}/.local/bin/slider $out/bin/slider
    '';

    meta = {
      description = "Give a file with images and timecodes and creates a video slideshow of them.";
      homepage = "https://github.com/LukeSmithXYZ/voidrice";
    };
  }
