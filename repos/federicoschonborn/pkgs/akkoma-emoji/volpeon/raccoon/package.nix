{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "volpeon-raccoon";
  version = "1.1";

  src = fetchzip {
    url = "https://volpeon.ink/emojis/raccoon/raccoon.zip";
    hash = "sha256-0MkE2C+bG6RFhnL3eciV+1XSDD+wzG+XVqDVVMDxDY0=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  meta = {
    description = "raccoon emoji pack";
    homepage = "https://volpeon.ink/emojis/raccoon/";
    license = lib.licenses.cc-by-nc-sa-40;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
