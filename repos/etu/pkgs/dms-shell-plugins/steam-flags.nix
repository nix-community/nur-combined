{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-steam-flags";
  version = "1.0.0-unstable-2026-05-17";

  src = fetchFromGitHub {
    owner = "Gateton";
    repo = "dank-bar-steam-flags";
    rev = "a96deedfe0c141241e1c51b2442da97f876d3b9d";
    hash = "sha256-iowZXD07I9COb2vpJHjrWLCOE+dbcgUeLPM6arsJX60=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell quick-access reference widget for Steam launch flags, performance tools, Proton env vars, and DXVK tweaks; click any flag to copy it";
    homepage = "https://github.com/Gateton/dank-bar-steam-flags";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
