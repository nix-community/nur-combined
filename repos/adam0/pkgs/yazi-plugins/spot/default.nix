{
  lib,
  fetchFromGitHub,
  mkYaziPlugin,
}:
mkYaziPlugin rec {
  pname = "spot.yazi";
  version = "0-unstable-2026-03-08";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "1d28640882b13d5724c6225f22ef999da458bf9d";
    hash = "sha256-iE1UFF7U/yRABOucDMPYyncm0VTCpNBgRQy+GoyXM1Y=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    description = "framework to build your own spotter";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/spot.yazi";
    license = lib.licenses.gpl3Only;
  };
}
