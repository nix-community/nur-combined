{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-prayer-times";
  version = "0-unstable-2026-09-11";

  src = fetchFromGitHub {
    owner = "muadzmo";
    repo = "prayertimes";
    rev = "d9ee1b1d51152b1d9ae792281d8e6a9a7f39a86a";
    hash = "sha256-E6i2I0BRCxj3lLbRRODrMDytK6uRnvFwcVqxPZA0v/8=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget displaying Islamic prayer times from the Aladhan API";
    homepage = "https://github.com/muadzmo/prayertimes";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
