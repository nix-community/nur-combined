{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "volpeon-wvrn";
  version = "1.1";

  src = fetchzip {
    url = "https://volpeon.ink/emojis/wvrn/wvrn.zip";
    hash = "sha256-CcXft1GqQi1xUz1UH+BXeHpMESSSSnKMFbWPpTK9Jwg=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  meta = {
    description = "wvrn emoji pack";
    homepage = "https://volpeon.ink/emojis/wvrn/";
    license = lib.licenses.cc-by-nc-sa-40;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
