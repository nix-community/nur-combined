{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-screenshot";
  version = "0-unstable-2026-09-07";

  src = fetchFromGitHub {
    owner = "JDKamalakar";
    repo = "DMS-Screenshot";
    rev = "d31161eaa4420ba3f54631956bf13bc35e3d46d5";
    hash = "sha256-/p85hztmwZlTqkzmhFiBdqmAcbY/u+yblgXp4CnPd1g=";
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
