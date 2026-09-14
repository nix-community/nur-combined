{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-stopwatch";
  version = "1.0.0-unstable-2026-06-21";

  src = fetchFromGitHub {
    owner = "hthienloc";
    repo = "dms-stopwatch";
    rev = "28a9d3e25a16f688f50af7222814e735edb739ac";
    hash = "sha256-MP33RrX3yxGWPvtrutyiaslqc6rkspxDFduiMRXRPHA=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell high-precision stopwatch widget for time tracking";
    homepage = "https://github.com/hthienloc/dms-stopwatch";
    license = licenses.gpl3Only;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
