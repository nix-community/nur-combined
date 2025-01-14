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
    hash = "sha256-RnWOr2bUZXcFGubQiEslB5bH6M3I43OelcGxJKklICw=";
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
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
