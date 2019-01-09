{ fetchurl, stdenv, lib, undmg }:

stdenv.mkDerivation rec {
  version = "1.0.96.181.gf6bc1b6b";
  name = "spotify-mac";

  src = fetchurl {
    url = "https://download.scdn.co/Spotify.dmg";
    sha256 = "0dpdim6prv0s9xmva8qb4qfif8c8k8pql2j7zfv2mahnssfdyg4y";
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
