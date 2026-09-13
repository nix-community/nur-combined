{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-world-clock";
  version = "0-unstable-2026-06-22";

  src = fetchFromGitHub {
    owner = "rochacbruno";
    repo = "WorldClock";
    rev = "f10e1f9c1ce14a819640fbea9e2787472cf3815f";
    hash = "sha256-7M9jdfy4/VX7sLmiXfjyERe7sFVKuHzqHgPSmT6XOAc=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell DankBar widget showing multiple timezones";
    homepage = "https://github.com/rochacbruno/WorldClock";
    license = licenses.agpl3Only;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
