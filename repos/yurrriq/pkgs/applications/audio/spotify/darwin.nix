{ fetchurl, stdenv, lib, undmg }:

stdenv.mkDerivation rec {
  version = "1.1.4.197.g92d52c4f";
  name = "spotify-mac";

  src = fetchurl {
    url = "https://download.scdn.co/Spotify.dmg";
    sha256 = "09sw2kr0pv5q0f6q77ar6jgdxcf210kxpxm7jca51nmwcxsm290s";
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
