{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "volpeon-bunhd_flip";
  version = "1.2.1";

  src = fetchzip {
    url = "https://volpeon.ink/emojis/bunhd/bunhd_flip.zip";
    hash = "sha256-lnUP1rPixAPufJrhbr/zSD9lu2h8u94UxV7ZIaPhiGE=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  meta = {
    description = "bunhd_flip emoji pack";
    homepage = "https://volpeon.ink/emojis/bunhd/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
