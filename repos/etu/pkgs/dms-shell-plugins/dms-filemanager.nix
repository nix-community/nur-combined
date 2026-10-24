{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dms-filemanager";
  version = "1.0.6-unstable-2026-10-23";

  src = fetchFromGitHub {
    owner = "suruibin";
    repo = "dms-filemanager";
    rev = "d70a62b69dcf5c946284b944984fbc52c6a069b5";
    hash = "sha256-j7saLMNoVLPCiqXfN7B0qevRykxs203QKImQ0TNlKHo=";
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
