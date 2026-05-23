{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot-cbz.yazi";
  version = "0-unstable-2026-05-22";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "7b29740861dffdab5acd6f71ea9cbe368449dfd3";
    hash = "sha256-6bmWS7RDDTuhc84190ATR3AXUtUhmajsGQ4+H3NIpUg=";
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
