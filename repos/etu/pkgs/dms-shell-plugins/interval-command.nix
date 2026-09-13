{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-interval-command";
  version = "0-unstable-2026-05-09";

  src = fetchFromGitHub {
    owner = "corcoran";
    repo = "dms-interval-command";
    rev = "8e9a4a45368b83cd0b62ccf7adf6e33c325ea9ae";
    hash = "sha256-5Th60t00wNITpI/ufnCqAl9/IquGUC9tS7PTGHvuKj0=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget that runs a command on a custom interval and displays its output in the bar, supporting multiple instances with different commands";
    homepage = "https://github.com/corcoran/dms-interval-command";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
