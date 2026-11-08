{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot.yazi";
  version = "0-unstable-2026-11-07";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "937ae3b151155f9c571c51b8ee5f43115d3872c7";
    hash = "sha256-Sc452SDksieYR85wpXpE4h35Ijomm3OPlMuWNCbu6rI=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    # keep-sorted start
    description = "framework to build your own spotter";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/spot.yazi";
    license = lib.licenses.gpl3Only;
    # keep-sorted end
  };
}
