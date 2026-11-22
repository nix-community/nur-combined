{ lib
, resholve

  # Dependencies
, bash
, cavif
, exiftool
, file
, gnused
, guetzli
, identity
, imagemagick
, libheif
, mozjpeg
, uutils-coreutils-noprefix
, zenity
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe getExe';
in
resholve.writeScriptBin "image-quality-gradient"
{
  interpreter = getExe bash;
  inputs = [ cavif exiftool file gnused guetzli identity imagemagick libheif mozjpeg uutils-coreutils-noprefix zenity ];
  execer = [
    "cannot:${getExe exiftool}"
    "cannot:${getExe identity}"
    "cannot:${getExe' uutils-coreutils-noprefix "mktemp"}"
    "cannot:${getExe' uutils-coreutils-noprefix "rm"}"
    "cannot:${getExe' uutils-coreutils-noprefix "touch"}"
    "cannot:${getExe zenity}"
  ];
}
  (readFile ./assets/image-quality-gradient.sh)
