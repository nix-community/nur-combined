{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "volpeon-neofox";
  version = "1.3";

  src = fetchzip {
    url = "https://volpeon.ink/emojis/neofox/neofox.zip";
    hash = "sha256-FSTVYP/Bt25JfLr/Ny1g9oI9aAvAYLYhct31j3XRXYc=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  meta = {
    description = "neofox emoji pack";
    homepage = "https://volpeon.ink/emojis/neofox/";
    license = lib.licenses.cc-by-nc-sa-40;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
