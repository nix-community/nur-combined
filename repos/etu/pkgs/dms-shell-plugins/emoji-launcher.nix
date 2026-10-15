{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-emoji-launcher";
  version = "0-unstable-2026-10-15";

  src = fetchFromGitHub {
    owner = "devnullvoid";
    repo = "dms-emoji-launcher";
    rev = "35ea4d653417840b9045c77a9adb0188a4900086";
    hash = "sha256-c81Jh/0sxAsLbIyy86Ikqr7uU3zzanMUsM9sWHccBMg=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell launcher plugin for searching and copying emoji and unicode characters";
    homepage = "https://github.com/devnullvoid/dms-emoji-launcher";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
