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
    hash = "sha256-DKtV6ArPgro6ujBac4dKhVxdCdQWSOMUsDxSjHWwSuE=";
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
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
