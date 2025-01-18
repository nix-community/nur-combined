{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "volpeon-gphn";
  version = "1.2";

  src = fetchzip {
    url = "https://volpeon.ink/emojis/gphn/gphn.zip";
    hash = "sha256-tJzn7TutJO6o6qCjJXXsLVTV+hYHLhO2JnCqwyZLxPg=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  meta = {
    description = "gphn emoji pack";
    homepage = "https://volpeon.ink/emojis/gphn/";
    license = lib.licenses.cc-by-nc-sa-40;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
