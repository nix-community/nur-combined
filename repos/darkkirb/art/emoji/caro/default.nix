{
  fetchFromGitHub,
  stdenvNoCC,
  imagemagick,
  lib,
  callPackage,
  oxipng,
  pngquant,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  stdenvNoCC.mkDerivation {
    pname = "caroline-stickers";
    version = source.date;
    src = fetchFromGitHub {
      owner = "CarolineHusky";
      repo = "CarolineStickers";
      inherit (source) rev sha256;
    };
    nativeBuildInputs = [
      imagemagick
      oxipng
      pngquant
    ];
    buildPhase = ''
      rm credits_*.png

      mv "bluefox_thanks I hate it.png" "bluefox_thanks_I_hate_it.png"

      mogrify -resize 256x256\> *.png

      find . -type f -name '*.png' -execdir ${../../../lib/crushpng.sh} {} {}.new 40000 \;
      for f in $(find . -type f -name '*.new'); do
        mv $f ${"$"}{f%.new}
      done
    '';
    installPhase = ''
      mkdir $out
      mv *.png $out
    '';
    meta = {
      description = "CarolineHusky stickers";
      license = lib.licenses.cc-by-nc-sa-40;
    };
    passthru.updateScript = [../../../scripts/update-git.sh "https://github.com/CarolineHusky/CarolineStickers" "art/emoji/caro/source.json"];
  }
