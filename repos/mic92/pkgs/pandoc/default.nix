{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "pandoc-bin";
  version = "2.11.0.4";

  src = fetchurl {
    url = "https://github.com/jgm/pandoc/releases/download/${version}/pandoc-${version}-linux-amd64.tar.gz";
    sha256 = "sha256-lOBw8+/4P6BpJGEEfb97zQ9Y2W8yNcZtc2aiLkJ4asA=";
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
    homepage = "https://github.com/jgm/pandoc";
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.unix;
  };
}
