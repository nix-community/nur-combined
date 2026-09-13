{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-converter";
  version = "0-unstable-2026-07-06";

  src = fetchFromGitHub {
    owner = "viewerofall-labs";
    repo = "weather-viewer";
    rev = "45ab60d67079d23b5c1fbac506aec825e9d3178c";
    hash = "sha256-nD+/+iGNi5z0iJ8s0c3WfwDNzOVmW4U7w6SLAnZv3k4=";
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
