{ fetchurl, stdenv, lib, undmg }:

stdenv.mkDerivation rec {
  version = "1.0.95.289.g342899da";
  name = "spotify-mac";

  src = fetchurl {
    url = "https://download.scdn.co/Spotify.dmg";
    sha256 = "0isk7wkdffd2hf4m7786w0g16b1n70n2bqzlk9s2c1v008642gxy";
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
