{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-niri-windows";
  version = "0-unstable-2026-09-09";

  src = fetchFromGitHub {
    owner = "rochacbruno";
    repo = "DankNiriWindows";
    rev = "411d5ee9f7707029f4c12c824ec3b24ca6756a0d";
    hash = "sha256-+Ju8cbw1yWWW2K2Gpl7nTdkjINqXBD4ktl5g8OhuIEg=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell launcher plugin to list and switch to open Niri windows";
    homepage = "https://github.com/rochacbruno/DankNiriWindows";
    license = licenses.agpl3Only;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
