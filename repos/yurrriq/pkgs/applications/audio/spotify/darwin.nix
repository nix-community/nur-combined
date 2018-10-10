{ fetchurl, stdenv, lib, undmg }:

stdenv.mkDerivation rec {
  version = "1.0.90.268.ga8a0ceb4";
  name = "spotify-mac";

  src = fetchurl {
    url = "https://download.scdn.co/Spotify.dmg";
    sha256 = "1bk8amhs15l86ms2xby11zci86viifj1zsvk1mqgg7v9n4gfsva2";
  };

  buildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r . $out/Applications/Spotify.app
  '';

  meta = with lib; {
    homepage = https://www.spotify.com/;
    description = "Play music from the Spotify music service";
    license = stdenv.lib.licenses.unfree;
    maintainers = with stdenv.lib.maintainers; [ matthewbauer yurrriq ];
    platforms = platforms.darwin;
  };
}
