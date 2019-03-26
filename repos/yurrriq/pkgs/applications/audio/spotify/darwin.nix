{ fetchurl, stdenv, lib, undmg }:

stdenv.mkDerivation rec {
  version = "1.1.2.285.ga97985ef";
  name = "spotify-mac";

  src = fetchurl {
    url = "https://download.scdn.co/Spotify.dmg";
    sha256 = "1kd8jhn5lbda5bhy7fjwkpydmvgp3x6kp2rd3806c6fxn92ff9j6";
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
