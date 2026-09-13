{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-simple-audio-control";
  version = "0-unstable-2026-07-31";

  src = fetchFromGitHub {
    owner = "Dadangdut33";
    repo = "dms-plugins";
    rev = "63fe6b87c497f1f7c2ea61432716817db1c5c3a4";
    hash = "sha256-/iIqBej8dFwOQpvO9PXFvnDwZMSA7IykzaQjl5xoJUs=";
  };

  sourceRoot = "source/SimpleAudioControl";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell DankBar widget for controlling audio output and input, inspired by the Noctalia Shell audio widget";
    homepage = "https://github.com/Dadangdut33/dms-plugins";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
