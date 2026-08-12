{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot-audio.yazi";
  version = "0-unstable-2026-06-27";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "ce325af662cbdd438194c68b6d69a3ff59c1b305";
    hash = "sha256-5+Wopb+W0STi1JMTDnjmIXorZEzDzSdMfdHLK9vl8xs=";
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
