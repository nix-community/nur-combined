{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-display-settings";
  version = "0-unstable-2026-05-18";

  src = fetchFromGitHub {
    owner = "lucyfire";
    repo = "dms-plugins";
    rev = "c99ba77c848721fbb8b8c3307638ea10d5dccdd9";
    hash = "sha256-FLC/0rktMTYaVJ/gvuTw6UryyzgR/OEiNIZk+5O1XuI=";
  };

  sourceRoot = "source/displaySettings";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget to turn displays on and off under Hyprland";
    homepage = "https://github.com/lucyfire/dms-plugins";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
