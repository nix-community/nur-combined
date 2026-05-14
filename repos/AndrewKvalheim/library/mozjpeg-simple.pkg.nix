{ lib
, resholve

  # Dependencies
, bash
, exiftool
, file
, imagemagick
, libheif
, mozjpeg
, uutils-coreutils
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe getExe';

  uutils-coreutils' = uutils-coreutils.override { prefix = null; };
in
resholve.writeScriptBin "mozjpeg" {
  interpreter = getExe bash;
  inputs = [ exiftool file imagemagick libheif mozjpeg uutils-coreutils' ];
  execer = [
    "cannot:${getExe exiftool}"
    "cannot:${getExe' uutils-coreutils' "mktemp"}"
  ];
} (readFile ./assets/mozjpeg.sh)
