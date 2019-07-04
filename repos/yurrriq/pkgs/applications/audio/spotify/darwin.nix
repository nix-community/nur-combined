{ fetchurl, stdenv, lib, undmg }:

stdenv.mkDerivation rec {
  pname = "spotify";
  version = "1.1.10.540.gfcf0430f";

  src = fetchurl {
    url = "https://download.scdn.co/Spotify.dmg";
    sha256 = "1nrrdfncghq8bb9gph7f0jvzk1dc4y0hvmldj0mxgcx7rcyjlpfy";
  };

  buildInputs = [ undmg ];

  installPhase = ''
    install -dm755 "$out/Applications"
    cp -r . "$_/Spotify.app"
  '';

  meta = with lib; {
    homepage = https://www.spotify.com/;
    description = "Play music from the Spotify music service";
    license = licenses.unfree;
    maintainers = with maintainers; [ matthewbauer yurrriq ];
    platforms = platforms.darwin;
  };
}
