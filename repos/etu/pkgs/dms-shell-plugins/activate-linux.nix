{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-activate-linux";
  version = "0-unstable-2026-06-21";

  src = fetchFromGitHub {
    owner = "hthienloc";
    repo = "dms-activate-linux";
    rev = "34f359aedcac9d27ff5df51d43cc41031ea00f80";
    hash = "sha256-iWfw7WF6EiLUnsQgsyJWGuacU09eyZZRdMBbRp7E/DA=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell desktop widget that adds an \"Activate Windows\"-style watermark to the bottom-right of the screen";
    homepage = "https://github.com/hthienloc/dms-activate-linux";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
