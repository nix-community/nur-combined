{ stdenv, fetchwebarchive }:

stdenv.mkDerivation {
  pname = "sendmap20";
  version = "4.2";

  src = fetchwebarchive {
    url = "http://cgpsmapper.com/download/sendmap20.gz";
    timestamp = "20160622234550";
    sha256 = "08fm3q3qpirxd2l6rwffs2h997vk04bl4jvq8fbjlymrsmdlqx4s";
  };

  sourceRoot = ".";
  unpackCmd = "gunzip -c $curSrc > sendmap20";

  dontFixup = true;
  doInstallCheck = true;

  installPhase = "install -Dm755 sendmap20 -t $out/bin";

  installCheckPhase = "$out/bin/sendmap20 -h";

  meta = with stdenv.lib; {
    description = "Software for uploading maps to your GPS";
    homepage = "https://web.archive.org/web/20160620061746if_/http://www.cgpsmapper.com";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "i686-linux" "x86_64-linux" ];
    skip.ci = true;
  };
}
