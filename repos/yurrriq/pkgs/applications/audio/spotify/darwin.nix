{ fetchurl, stdenv, lib, undmg }:

stdenv.mkDerivation rec {
  version = "1.1.9.383.g9f48828e";
  name = "spotify-mac";

  src = fetchurl {
    url = "https://download.scdn.co/Spotify.dmg";
    sha256 = "1bxxvrzx15k7pzax90nf9fa8jp8jgwm0s5pwv2bnazv684z9v8nn";
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
