{ resholve

  # Dependencies
, bash
, coreutils
, exiftool
, file
, imagemagick
, libheif
, mozjpeg
}:

let
  inherit (builtins) readFile;
in
resholve.writeScriptBin "mozjpeg" {
  interpreter = "${bash}/bin/bash";
  inputs = [ coreutils exiftool file imagemagick libheif mozjpeg ];
  execer = [ "cannot:${exiftool}/bin/exiftool" ];
} (readFile ./resources/mozjpeg)
