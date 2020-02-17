{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "cgpsmapper";
  version = "0093c";

  src = fetchurl {
    url = "https://web.archive.org/web/20160620102839if_/http://www.cgpsmapper.com/download/${pname}-static.gz";
    sha256 = "0h2xjkzkg566bgvg8gbl1hmjjimv2xbhv2csd54naq1vqphqjchx";
  };

  sourceRoot = ".";
  unpackCmd = ''
    gunzip -c $curSrc > cgpsmapper-static
  '';

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    install -Dm755 cgpsmapper-static -t "$out/bin"
  '';

  meta = with stdenv.lib; {
    description = "GIS converter into GARMIN compatible format maps";
    homepage = "https://web.archive.org/web/20160620061746if_/http://www.cgpsmapper.com";
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
