{ stdenv, callPackage, buildEnv, lowPrio, ffmpeg, imagemagick }:
let
  voidrice = callPackage ../voidrice.nix { };
in
  stdenv.mkDerivation {
    name = "slider";

    src = voidrice;

    buildPhase = ''
      sed -i 's:ffmpeg:${ffmpeg}/bin/ffmpeg:g' .local/bin/slider
      sed -i 's:convert:${imagemagick}/bin/convert:g' .local/bin/slider
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp  .local/bin/slider $out/bin/slider
    '';

    meta = {
      description = "Give a file with images and timecodes and creates a video slideshow of them.";
      homepage = "https://github.com/LukeSmithXYZ/voidrice";
    };
  }
