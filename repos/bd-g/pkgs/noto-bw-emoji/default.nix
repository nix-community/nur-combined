{ lib, stdenv, pkgs }:
let
  pname = "noto-bw-emoji";
  version = "v39";
  font-family-name = "Noto Emoji";
  regular-url = "http://fonts.gstatic.com/s/notoemoji/v39/bMrnmSyK7YY-MEu6aWjPDs-ar6uWaGWuob-r0jwvS-FGJCMY.ttf";
  regular-hash = "Zfwh9q2GrL5Dwp+J/8Ddd2IXCaUXpQ7dE3CqgCMMyPs=";
in
stdenv.mkDerivation {
  inherit pname version font-family-name;

  src = pkgs.fetchurl {
    url = regular-url;
    sha256 = regular-hash;
  };
  dontUnpack = true;

  passthru = {
    updateScript = ./update.sh;
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/noto
    cp $src $out/share/fonts/noto/NotoEmoji.ttf
    runHook postInstall
  '';

  meta = with lib; {
    description = "Black-and-White Noto emoji fonts from google";
    homepage = "https://fonts.google.com/noto/specimen/Noto+Emoji";
    license = with licenses; [ asl20 ];
    platforms = platforms.all;
  };
}
