{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot-cbz.yazi";
  version = "0-unstable-2026-05-29";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "0fd127f963dc1afa228cc0fcc76c796331f7c74f";
    hash = "sha256-AW7PQJ9P6oYZHyH2Vp8CgWGGDy/yhscOl5PWFiv+mqA=";
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
