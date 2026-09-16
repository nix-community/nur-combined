{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-hooks";
  version = "0-unstable-2026-09-15";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dms-plugins";
    rev = "bb90a1db7d540e64ae049c5906afba9b24baa865";
    hash = "sha256-NYmw2wCZYAKNU1xcodKMDXs5wwtAguOUNazRxcLjsUE=";
  };

  sourceRoot = "source/DankHooks";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell daemon plugin to execute custom scripts on system events like wallpaper changes, theme updates, and battery level changes";
    homepage = "https://github.com/AvengeMedia/dms-plugins";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
