{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dms-filemanager";
  version = "1.0.6-unstable-2026-09-14";

  src = fetchFromGitHub {
    owner = "suruibin";
    repo = "dms-filemanager";
    rev = "712154f3eb5dae789ce03f0700488163928395fa";
    hash = "sha256-zZo626so60kUB2RMwD5FKBXzK59kyUtUn7NXQblB6OU=";
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
