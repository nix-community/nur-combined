{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-github-heatmap-revive";
  version = "0-unstable-2026-10-11";

  src = fetchFromGitHub {
    owner = "JDKamalakar";
    repo = "DMS-GitHub_HeatMap";
    rev = "7dc9351300edbc5a7cf8f48187123efc9ea9a1ef";
    hash = "sha256-i62d0eLcX3GRKPg1Wtf77qhyyznUu8yTuPPA/JSXYLg=";
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
