{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-github-heatmap-revive";
  version = "0-unstable-2026-09-07";

  src = fetchFromGitHub {
    owner = "JDKamalakar";
    repo = "DMS-GitHub_HeatMap";
    rev = "2d61d19eb078563029d50c15be02c2be24050c40";
    hash = "sha256-oreRDf5KPDDj8tT8Bi16C5UIC6YMUukPjrXDwz5fw1M=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget showing a GitHub contribution heatmap with color-coded activity levels";
    homepage = "https://github.com/JDKamalakar/DMS-GitHub_HeatMap";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
