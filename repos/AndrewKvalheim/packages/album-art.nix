{ fetchurl
, lib
, makeDesktopItem
, resholve

  # Dependencies
, bash
, imagemagick
, kitty
, mozjpeg
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;

  album-art = resholve.writeScriptBin "album-art" {
    interpreter = getExe bash;
    inputs = [ imagemagick kitty mozjpeg ];
    execer = [ "cannot:${getExe kitty}" ];
  } (readFile ./resources/album-art);
in
makeDesktopItem {
  categories = [ "Utility" ];
  desktopName = "Format album art";
  name = "album-art";
  icon = fetchurl {
    url = "https://github.com/metabrainz/picard/raw/1cbb7a8522f945e602744c6e6aa935ec778b3cce/resources/images/CoverArtShadow.png";
    hash = "sha256-BOtmn89tOZga0PIOYYYoHr/gB/16Z3DCY7e9xU9wYU8=";
  };
  exec = "${getExe album-art} %f";
  mimeTypes = [ "image/jpeg" "image/png" ];
}
