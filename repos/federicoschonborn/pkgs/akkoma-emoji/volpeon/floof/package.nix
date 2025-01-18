{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "volpeon-floof";
  version = "1.0";

  src = fetchzip {
    url = "https://volpeon.ink/emojis/floof/floof.zip";
    hash = "sha256-83+wd2gPIaSV3OMY2GpvtAgG/FZha0Cx3/LZ1jwAg9s=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  meta = {
    description = "floof emoji pack";
    homepage = "https://volpeon.ink/emojis/floof/";
    license = lib.licenses.cc-by-nc-sa-40;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
