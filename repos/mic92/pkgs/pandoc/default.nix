{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "pandoc-bin";
  version = "2.9.2.1";

  src = fetchurl {
    url = "https://github.com/jgm/pandoc/releases/download/${version}/pandoc-${version}-linux-amd64.tar.gz";
    sha256 = "1y0c9cdhk1w7l3qx3l265dzgjcb673qqhmxsnk0lhz9bpn0sjqav";
  };

  installPhase = ''
    mkdir $out
    cp -r * $out
  '';

  installCheckPhase = ''
    $out/bin/pandoc --version
  '';

  dontStrip = true;

  meta = with stdenv.lib; {
    description = "Universal markup converter (static binary to save disk space)";
    homepage = https://github.com/jgm/pandoc;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.unix;
  };
}
