{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "preview-cbz.yazi";
  version = "0-unstable-2026-11-10";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "aebeaa7eec76f7a22e1218b5c4841ab87acd56da";
    hash = "sha256-iPe0BlQSY9/qnklwL2WyaDh2jCCIDEUREXI9l3h6IAQ=";
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
