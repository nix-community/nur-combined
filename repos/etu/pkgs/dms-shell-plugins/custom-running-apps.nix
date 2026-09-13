{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-custom-running-apps";
  version = "0-unstable-2026-06-28";

  src = fetchFromGitHub {
    owner = "heyitsmikey128";
    repo = "DankCustomRunningApps";
    rev = "87a75c9ae29bda4232f99e1ea85d777f2a5e3140";
    hash = "sha256-5hnDBQF6kmWFu7YM440fIkCeZ32TErWjomL9yzqKD7c=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell flexible DankBar widget for showing running apps";
    homepage = "https://github.com/heyitsmikey128/DankCustomRunningApps";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
