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
    hash = "sha256-N8A5YqpJK2vz+aGRQ40l+V39w6SNE3JLNyVxZxNkVIo=";
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
