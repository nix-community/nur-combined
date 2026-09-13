{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-warp-toggle";
  version = "0-unstable-2026-06-26";

  src = fetchFromGitHub {
    owner = "ahmed-mekky";
    repo = "dms-warp-toggle";
    rev = "3bee1e952c626071167c4e0aedad6241f7f624e0";
    hash = "sha256-SgUWuMG5bDuFbdXvWmSUfgOyiq2kX/6iovUIWITDxsE=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget to toggle Cloudflare WARP via warp-cli with real-time status updates";
    homepage = "https://github.com/ahmed-mekky/dms-warp-toggle";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
