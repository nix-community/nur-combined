{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-network-indicator";
  version = "0-unstable-2026-08-15";

  src = fetchFromGitHub {
    owner = "gemb0-0";
    repo = "Network-Indicator";
    rev = "81d948dbabceba0f446a0441f3901a4d6b6b2f3a";
    hash = "sha256-YUFCzEO/8GkfvwzXBZsylw0vwYw+AnIs+cKHXWnt0qo=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "Real-time network speed monitor for the DankMaterialShell DankBar showing upload and download speeds";
    homepage = "https://github.com/gemb0-0/Network-Indicator";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
