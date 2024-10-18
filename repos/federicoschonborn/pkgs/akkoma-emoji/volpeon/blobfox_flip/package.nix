{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "volpeon-blobfox_flip";
  version = "1.6";

  src = fetchzip {
    url = "https://volpeon.ink/emojis/blobfox/blobfox_flip.zip";
    hash = "sha256-0vXcwHYL8W2fH/Pc1ruo97v1DboOaffGNvNp7c/M8nw=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  meta = {
    description = "blobfox_flip emoji pack";
    homepage = "https://volpeon.ink/emojis/blobfox/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
