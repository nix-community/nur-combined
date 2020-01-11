{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "pandoc-bin";
  version = "2.9.1.1";

  src = fetchurl {
    url = "https://github.com/jgm/pandoc/releases/download/${version}/pandoc-${version}-linux-amd64.tar.gz";
    sha256 = "1r9qqi1am6zvw7sdpasgip9fykdwqchvlb51sl8r4jyjbr2v5zw0";
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
