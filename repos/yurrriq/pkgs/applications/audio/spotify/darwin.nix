{ fetchurl, stdenv, lib, undmg }:

stdenv.mkDerivation rec {
  version = "1.1.6.113.gb388fe17";
  name = "spotify-mac";

  src = fetchurl {
    url = "https://download.scdn.co/Spotify.dmg";
    sha256 = "0kpvxk3h2cjfl5bxslzbxs74ivlj21mm33093kw878lpzacid509";
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
