{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-command-runner";
  version = "0-unstable-2026-10-03";

  src = fetchFromGitHub {
    owner = "devnullvoid";
    repo = "dms-command-runner";
    rev = "ea59490eede60d7dc87697b670f1eccc6ad54593";
    hash = "sha256-EmYYvPvSwG7ELTgRS6tcVEqFgyk8uYiB491Gp7nkPvs=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell launcher plugin to execute shell commands with history tracking, common shortcuts, and terminal/background execution modes";
    homepage = "https://github.com/devnullvoid/dms-command-runner";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
