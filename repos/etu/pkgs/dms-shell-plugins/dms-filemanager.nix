{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dms-filemanager";
  version = "0-unstable-2026-09-14";

  src = fetchFromGitHub {
    owner = "suruibin";
    repo = "dms-filemanager";
    rev = "c7439d44a04dab6161b4a5889bd7a0da107d500f";
    hash = "sha256-oWSjTEwFI+wtOQFPyDSJnHyG0JgXGjgj/wX7Fp9PY3E=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell file manager plugin to browse, manage, and organize files on your desktop";
    homepage = "https://github.com/suruibin/dms-filemanager";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
