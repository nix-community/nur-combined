{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "pandoc-bin";
  version = "2.7.3";

  src = fetchurl {
    url = "https://github.com/jgm/pandoc/releases/download/${version}/pandoc-${version}-linux.tar.gz";
    sha256 = "0xfvmfw1yn72iiy52ia7sk6hgrvn62qwkw009l02j0y55va5yxzb";
  };

  installPhase = ''
    mkdir $out
    cp -r * $out
  '';

  meta = with stdenv.lib; {
    description = "Universal markup converter (static binary to save disk space)";
    homepage = https://github.com/jgm/pandoc;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.unix;
  };
}
