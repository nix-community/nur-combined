{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-hidden-bar";
  version = "2.5.0-unstable-2026-07-02";

  src = fetchFromGitHub {
    owner = "hthienloc";
    repo = "dms-hidden-bar";
    rev = "21b127f44bb5ee42621df94f509a0410ec803e55";
    hash = "sha256-gCmK9oIdz9lUCrUJqyDCkZgNG5XfmqUWqe8xRz7MgJw=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell plugin to hide/show bar widgets with a click or hover";
    homepage = "https://github.com/hthienloc/dms-hidden-bar";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
