{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "volpeon-bunhd";
  version = "1.2.1";

  src = fetchzip {
    url = "https://volpeon.ink/emojis/bunhd/bunhd.zip";
    hash = "sha256-b/yOI/dqulrs9rBFtMRCKOYuguM+xRif/02rIfcyNO8=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  meta = {
    description = "bunhd emoji pack";
    homepage = "https://volpeon.ink/emojis/bunhd/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
