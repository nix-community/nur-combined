{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-weather-art";
  version = "0-unstable-2026-07-06";

  src = fetchFromGitHub {
    owner = "viewerofall-labs";
    repo = "weather-viewer";
    rev = "45ab60d67079d23b5c1fbac506aec825e9d3178c";
    hash = "sha256-nD+/+iGNi5z0iJ8s0c3WfwDNzOVmW4U7w6SLAnZv3k4=";
  };

  sourceRoot = "source/weatherArt";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell dynamic weather art widget with responsive ASCII scenes, customizable stats, and theme support";
    homepage = "https://github.com/viewerofall-labs/weather-viewer";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
