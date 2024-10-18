{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "volpeon-neocat";
  version = "1.1";

  src = fetchzip {
    url = "https://volpeon.ink/emojis/neocat/neocat.zip";
    hash = "sha256-FLtaIqBZqZGC51NX6HiwEzWBlx1GpstZcgpnMDFTuQk=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  meta = {
    description = "neocat emoji pack";
    homepage = "https://volpeon.ink/emojis/neocat/";
    license = lib.licenses.cc-by-nc-sa-40;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
