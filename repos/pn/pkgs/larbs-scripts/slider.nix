{ stdenv, callPackage, buildEnv, ffmpeg, imagemagick }:
let
  voidrice = callPackage ../voidrice.nix { };
in
  buildEnv {
    name = "slider";
    paths = [
      ffmpeg
      imagemagick
    ];
    postBuild = ''
      cp  ${voidrice}/.local/bin/slider $out/bin/slider
    '';

    meta = {
      description = "Give a file with images and timecodes and creates a video slideshow of them.";
      homepage = "https://github.com/LukeSmithXYZ/voidrice";
    };
  }
