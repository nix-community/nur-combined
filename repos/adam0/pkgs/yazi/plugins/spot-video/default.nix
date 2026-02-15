{
  lib,
  fetchFromGitHub,
  mkYaziPlugin,
}:
mkYaziPlugin rec {
  pname = "spot-video.yazi";
  version = "unstable-2026-02-15";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "f3608defbcdf2d1485a7b8404716015b44fdb32c";
    hash = "sha256-3CJrNnByxfR2OoRxXrlkBcFz2QHvocPnWIM3qyb/2WM=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    description = "video metadata";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/spot-video.yazi";
    license = lib.licenses.gpl3Only;
  };
}
