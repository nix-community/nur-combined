{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-screenshot";
  version = "1.7.0-unstable-2026-10-12";

  src = fetchFromGitHub {
    owner = "JDKamalakar";
    repo = "DMS-Screenshot";
    rev = "9336067259bcd7d9ef601086ef500dec3a5009d0";
    hash = "sha256-6p3cTFIO/jnkYNkIns5byMf5jOCAEG5JKN+MXV6ztfg=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell plugin to control screenshot actions from the widget and control center";
    homepage = "https://github.com/JDKamalakar/DMS-Screenshot";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
