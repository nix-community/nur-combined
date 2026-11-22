{ lib
, resholve

  # Dependencies
, bash
, exiftool
, file
, imagemagick
, libheif
, mozjpeg
, uutils-coreutils-noprefix
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe getExe';
in
resholve.writeScriptBin "mozjpeg" {
  interpreter = getExe bash;
  inputs = [ exiftool file imagemagick libheif mozjpeg uutils-coreutils-noprefix ];
  execer = [
    "cannot:${getExe exiftool}"
    "cannot:${getExe' uutils-coreutils-noprefix "mktemp"}"
  ];
} (readFile ./assets/mozjpeg.sh)
