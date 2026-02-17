{
  lib,
  fetchFromGitHub,
  mkYaziPlugin,
}:
mkYaziPlugin rec {
  pname = "spot-cbz.yazi";
  version = "unstable-2026-02-13";

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
    description = "comic books that have ComicInfo.xml";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/spot-cbz.yazi";
    license = lib.licenses.gpl3Only;
  };
}
