{ stdenv, fetchurl }:
with stdenv.lib;

stdenv.mkDerivation {
  name = "hyperion-rpi3";

  src = fetchurl {
    url = "https://sourceforge.net/projects/hyperion-project/files/release/hyperion_rpi3.tar.gz";
    sha256 = "04rf1q68b80pmb9m3pqmbr761hb3zpqsb7k2bjgd8x8kyw21dh6z";
  };

  buildPhase = "";
  installPhase = ''
    mkdir -p $out
    cp -r bin $out/bin
  '';

  meta = {
    description = "Hyperion is an open source ambient light software. Feel free to join us and contribute new features!";
    homepage = "https://hyperion-project.org/";
  };
}
