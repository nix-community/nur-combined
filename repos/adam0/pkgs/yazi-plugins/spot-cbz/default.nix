{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot-cbz.yazi";
  version = "0-unstable-2026-05-06";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "695c58bc0afd2b2981c05fe5f534e68a9f124479";
    hash = "sha256-E7yZf4LVXyyDzdQhtjCZR1vvGCr/grG++wYoXdJKB5c=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    # keep-sorted start
    description = "comic books that have ComicInfo.xml";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/spot-cbz.yazi";
    license = lib.licenses.gpl3Only;
    # keep-sorted end
  };
}
