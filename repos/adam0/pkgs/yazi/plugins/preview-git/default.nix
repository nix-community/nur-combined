{
  lib,
  fetchFromGitHub,
  mkYaziPlugin,
}:
mkYaziPlugin rec {
  pname = "preview-git.yazi";
  version = "unstable-2026-03-08";

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
    description = "showing git info by hovering over `.git/` directory";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/preview-git.yazi";
    license = lib.licenses.gpl3Only;
  };
}
