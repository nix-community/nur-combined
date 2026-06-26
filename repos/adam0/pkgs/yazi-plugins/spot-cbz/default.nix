{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot-cbz.yazi";
  version = "0-unstable-2026-06-25";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "dc36177ae7b6413bf0d05bc4cfb641d5418d52f0";
    hash = "sha256-S2rwHtEcWDyIfMunvdm8rc5hXXeu4PCLj2qEcHEgr4E=";
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
