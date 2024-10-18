{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "volpeon-fox";
  version = "1.1";

  src = fetchzip {
    url = "https://volpeon.ink/emojis/fox/fox.zip";
    hash = "sha256-IHINraiVnPrDHFjus1hGc8mduZ1pHF+mZ+AkYVE1PxY=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  meta = {
    description = "fox emoji pack";
    homepage = "https://volpeon.ink/emojis/fox/";
    license = lib.licenses.cc-by-nc-sa-40;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
