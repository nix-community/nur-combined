{ fetchurl, stdenv, lib, undmg }:

stdenv.mkDerivation rec {
  version = "1.1.8.439.g8502297d";
  name = "spotify-mac";

  src = fetchurl {
    url = "https://download.scdn.co/Spotify.dmg";
    sha256 = "0r1dz8as6hzfwhkmzjxiz9rdzaw9x671x0zhz5amaqj7gff3qwki";
  };

  buildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r . $out/Applications/Spotify.app
  '';

  meta = with lib; {
    homepage = https://www.spotify.com/;
    description = "Play music from the Spotify music service";
    license = licenses.unfree;
    maintainers = with maintainers; [ matthewbauer yurrriq ];
    platforms = platforms.darwin;
  };
}
