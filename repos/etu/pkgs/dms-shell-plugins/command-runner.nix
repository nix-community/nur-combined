{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-command-runner";
  version = "0-unstable-2026-07-04";

  src = fetchFromGitHub {
    owner = "devnullvoid";
    repo = "dms-command-runner";
    rev = "5c2cab404335ceb96c60cf9e97a9682994209cd4";
    hash = "sha256-3dWzbyFh+5VygSTgMAVR+hn5ltv8GFMsX0EdW/lXdqw=";
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
