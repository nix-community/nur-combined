{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-pkg-update";
  version = "0-unstable-2026-05-16";

  src = fetchFromGitHub {
    owner = "rahulmysore23";
    repo = "dms-pkg-update";
    rev = "a17dd21f6f72582ede70646db9d0eefc302d05bc";
    hash = "sha256-c0d0urqMo/2O1sDTj48beiv3qWHRpFnBctc1PzKz6pw=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget to check and manage DNF and Flatpak package updates from the bar";
    homepage = "https://github.com/rahulmysore23/dms-pkg-update";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
