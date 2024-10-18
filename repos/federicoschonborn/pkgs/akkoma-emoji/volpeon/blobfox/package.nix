{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "volpeon-blobfox";
  version = "1.6";

  src = fetchzip {
    url = "https://volpeon.ink/emojis/blobfox/blobfox.zip";
    hash = "sha256-MR+ULE+0GKjMm5WoZ2t1jlK1TrhRx6DLfRg8q2cV/0k=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  meta = {
    description = "blobfox emoji pack";
    homepage = "https://volpeon.ink/emojis/blobfox/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
