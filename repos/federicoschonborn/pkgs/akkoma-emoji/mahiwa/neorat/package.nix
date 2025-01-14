{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  name = "mahiwa-neorat";

  src = fetchzip {
    url = "https://emoji-repo.absturztau.be/repo/neorat.zip";
    hash = "sha256-MwOxj1Kb0tVjpHy5C7E5dAXdiUSetH4iQUpz/q1Opbo=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  meta = {
    description = "A set of emojis featuring a rat";
    homepage = "https://mahiwa.monster/gift.html";
    license = lib.licenses.unfree; # TODO: ?
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
