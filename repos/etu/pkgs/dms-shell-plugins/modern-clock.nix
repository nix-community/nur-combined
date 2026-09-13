{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-modern-clock";
  version = "0-unstable-2026-08-09";

  src = fetchFromGitHub {
    owner = "beefsizzle";
    repo = "ModernClockDMS";
    rev = "0d11d9fb560547a2589d59e456598f7c94847bae";
    hash = "sha256-cD8Ho8PG8GqRBPFtgub02uIMgXVsd0P8AzTNuVYccEk=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "Minimal DankMaterialShell desktop clock with a large day name over the date and time, a port of Prayag2's KDE Modern Clock plasmoid";
    homepage = "https://github.com/beefsizzle/ModernClockDMS";
    license = licenses.gpl3Only;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
