{ lib
, resholve

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
  inherit (lib) getExe;
in
resholve.writeScriptBin "mozjpeg" {
  interpreter = getExe bash;
  inputs = [ coreutils exiftool file imagemagick libheif mozjpeg ];
  execer = [ "cannot:${getExe exiftool}" ];
} (readFile ./resources/mozjpeg)
