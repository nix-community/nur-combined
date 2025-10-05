{
  lib,
  stdenv,
  fetchwebarchive,
}:

stdenv.mkDerivation {
  pname = "cgpsmapper";
  version = "0093c";

  src = fetchwebarchive {
    url = "http://cgpsmapper.com/download/cgpsmapper-static.gz";
    timestamp = "20160817191046";
    hash = "sha256-HTKJ4cU7YGVJaZqJDVcXu0YpKwx0PfT2W8aUN/+UXUA=";
  };

  sourceRoot = ".";
  unpackCmd = "gunzip -c $curSrc > cgpsmapper-static";

  dontFixup = true;
  doInstallCheck = true;

  installPhase = "install -Dm755 cgpsmapper-static -t $out/bin";

  installCheckPhase = "$out/bin/cgpsmapper-static -h";

  meta = {
    description = "GIS converter into GARMIN compatible format maps";
    homepage = "https://web.archive.org/web/20160620061746if_/http://www.cgpsmapper.com";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
    mainProgram = "cgpsmapper-static";
    skip.ci = true;
  };
}
