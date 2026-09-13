{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-vscode-launcher";
  version = "0-unstable-2026-02-25";

  src = fetchFromGitHub {
    owner = "sr-tream";
    repo = "dms-vscode-launcher";
    rev = "8db331b0dead8c463423860d7d9cbe682b5db8db";
    hash = "sha256-pofHCyQ8zAZNTMG/G6YqCx4P1GMjfo7uEJHw3LJUrw4=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell launcher plugin for quick access to recent Visual Studio Code files, folders, and projects";
    homepage = "https://github.com/sr-tream/dms-vscode-launcher";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
