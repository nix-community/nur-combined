{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "volpeon-vlpn";
  version = "1.1";

  src = fetchzip {
    url = "https://volpeon.ink/emojis/vlpn/vlpn.zip";
    hash = "sha256-NNBNGS9S2iZCj76xJ6PJdxyHCfpP+yoYVuX8ORzpYrs=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  meta = {
    description = "vlpn emoji pack";
    homepage = "https://volpeon.ink/emojis/vlpn/";
    license = lib.licenses.cc-by-nc-sa-40;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
