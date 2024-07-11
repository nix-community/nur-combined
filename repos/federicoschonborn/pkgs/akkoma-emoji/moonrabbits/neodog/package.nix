{
  lib,
  stdenv,
  fetchFromGitea,
}:

stdenv.mkDerivation {
  pname = "moonrabbits-neodog";
  version = "0-unstable-2024-07-09";

  src = fetchFromGitea {
    domain = "git.gay";
    owner = "moonrabbits";
    repo = "neodog";
    rev = "13e40f780f289d464488e87647eb9f0760ae1c81";
    hash = "sha256-+nPjGZdXfdb53FPb/ku5iiYRGqC3jTTP1sC1hOaEwYo=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    for dir in 256x animated; do
      cp $(find $dir -name "*.png") $out
    done

    runHook postInstall
  '';

  meta = {
    description = "Neodog emojis by @moonrabbits@shonk.phite.ro";
    homepage = "https://git.gay/moonrabbits/neodog";
    license = lib.licenses.cc-by-nc-sa-40;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
