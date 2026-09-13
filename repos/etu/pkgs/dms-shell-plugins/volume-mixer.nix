{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-volume-mixer";
  version = "0-unstable-2026-08-02";

  src = fetchFromGitHub {
    owner = "cwelsys";
    repo = "dms-volume-mixer";
    rev = "353e00b659a16df07105b16c8790e6b526743471";
    hash = "sha256-RiMm8ZHphrZ6VuUUja0GrHe4EqUB/dI6EKfKaL8mtsU=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell standalone volume mixer widget for your bar";
    homepage = "https://github.com/cwelsys/dms-volume-mixer";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
