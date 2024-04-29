{ lib, stdenv, fetchurl, ... }:
let
  pname = "font-apple-color-emoji";
  version = "17.4";
  src = fetchurl {
    url = "https://github.com/samuelngs/apple-emoji-linux/releases/download/v${version}/AppleColorEmoji.ttf";
    sha256 = "486dc940bc9b858fdf317f97aa607f04a850481074375551a9af87ea569550f1";
  };
in
stdenv.mkDerivation {
  inherit pname version src;
  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp $src $out/share/fonts/truetype/${pname}.ttf
    '';

  meta = with lib; {
    description = "Apple Color Emoji font for Linux";
    homepage = "https://github.com/samuelngs/apple-emoji-linux";
    license = licenses.apsl20;
  };
}
