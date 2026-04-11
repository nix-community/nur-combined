{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "preview-cbz.yazi";
  version = "0-unstable-2026-04-09";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "a36ff719194a5bbc745e7f0674dc5fee0ff40b1f";
    hash = "sha256-h9s+L0XlDniECAzCY1LUAmEQ5F3QujtJzljOOrhlXWQ=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    # keep-sorted start
    description = "comic books and manga";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/preview-cbz.yazi";
    license = lib.licenses.gpl3Only;
    # keep-sorted end
  };
}
