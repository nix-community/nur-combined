{ lib
, resholve

  # Dependencies
, bash
, exiftool
, file
, gnused
, guetzli
, identity
, imagemagick
, libheif
, uutils-coreutils
, zenity
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe getExe';

  uutils-coreutils' = uutils-coreutils.override { prefix = null; };
in
resholve.writeScriptBin "guetzli-gradient"
{
  interpreter = getExe bash;
  inputs = [ exiftool file gnused guetzli identity imagemagick libheif uutils-coreutils' zenity ];
  execer = [
    "cannot:${getExe exiftool}"
    "cannot:${getExe identity}"
    "cannot:${getExe' uutils-coreutils' "mktemp"}"
    "cannot:${getExe' uutils-coreutils' "rm"}"
    "cannot:${getExe' uutils-coreutils' "touch"}"
    "cannot:${getExe zenity}"
  ];
}
  (readFile ./assets/guetzli-gradient.sh)
