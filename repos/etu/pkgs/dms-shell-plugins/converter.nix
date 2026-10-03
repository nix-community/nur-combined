{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-converter";
  version = "0-unstable-2026-10-02";

  src = fetchFromGitHub {
    owner = "viewerofall-labs";
    repo = "weather-viewer";
    rev = "1892857e462be9b830582d891e989a61fe194d75";
    hash = "sha256-cKcs+5tTFpUr9iyuag/CFxUNcVKyAyt1JNLNFXYOcsQ=";
  };

  sourceRoot = "source/converter";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell launcher plugin that converts units and colors: distance, weight, temperature, speed, volume, area, energy, and RGB/Hex/HSV/HSL";
    homepage = "https://github.com/viewerofall-labs/weather-viewer";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
