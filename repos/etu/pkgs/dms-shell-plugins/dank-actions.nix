{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-actions";
  version = "0-unstable-2026-09-15";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dms-plugins";
    rev = "bb90a1db7d540e64ae049c5906afba9b24baa865";
    hash = "sha256-NYmw2wCZYAKNU1xcodKMDXs5wwtAguOUNazRxcLjsUE=";
  };

  sourceRoot = "source/DankActions";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget that executes custom commands with dynamic output display and configurable icons";
    homepage = "https://github.com/AvengeMedia/dms-plugins";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
