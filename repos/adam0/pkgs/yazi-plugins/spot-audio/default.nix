{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot-audio.yazi";
  version = "0-unstable-2026-05-09";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "8a3b35db0a702a65b2aec2f0a37f5bc61b2b1188";
    hash = "sha256-kcITsNrHy5f0DhJDMpAnW6LgSOfqlAS1w51/jDdGU+w=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    # keep-sorted start
    description = "audio metadata";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/spot-audio.yazi";
    license = lib.licenses.gpl3Only;
    # keep-sorted end
  };
}
