{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "volpeon-drgn";
  version = "3.1";

  src = fetchzip {
    url = "https://volpeon.ink/emojis/drgn/drgn.zip";
    hash = "sha256-/2MpbxMJC92a4YhwG5rP6TsDC/q1Ng5fFq4xe2cBrrM=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  meta = {
    description = "drgn emoji pack";
    homepage = "https://volpeon.ink/emojis/drgn/";
    license = lib.licenses.cc-by-nc-sa-40;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
