{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "sendmap20";
  version = "4.2";

  src = fetchurl {
    url = "https://web.archive.org/web/20160622234550if_/http://cgpsmapper.com/download/${pname}.gz";
    sha256 = "08fm3q3qpirxd2l6rwffs2h997vk04bl4jvq8fbjlymrsmdlqx4s";
  };

  sourceRoot = ".";
  unpackCmd = "gunzip -c $curSrc > sendmap20";

  dontBuild = true;
  dontFixup = true;

  installPhase = "install -Dm755 sendmap20 -t $out/bin";

  meta = with stdenv.lib; {
    description = "Software for uploading maps to your GPS";
    homepage = "https://web.archive.org/web/20160620061746if_/http://www.cgpsmapper.com";
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
