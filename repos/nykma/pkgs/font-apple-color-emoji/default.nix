{ lib, stdenv, fetchurl, ... }:
let
  pname = "font-apple-color-emoji";
  version = "18.4";
  src = fetchurl {
    url = "https://github.com/samuelngs/apple-emoji-linux/releases/download/v${version}/AppleColorEmoji.ttf";
    sha256 = "sha256-pP0He9EUN7SUDYzwj0CE4e39SuNZ+SVz7FdmUviF6r0=";
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
