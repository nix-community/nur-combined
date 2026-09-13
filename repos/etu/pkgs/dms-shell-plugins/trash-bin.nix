{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-trash-bin";
  version = "0-unstable-2026-07-14";

  src = fetchFromGitHub {
    owner = "kerojiang";
    repo = "dms-transBin";
    rev = "95ee2a137eddca5c847ce983efe3478ec1be88c9";
    hash = "sha256-o/+ocLCBeA9wIZQwG5oeE8hu7DAo73iQ7/3Hck7iLvA=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget to monitor and manage your system trash from the status bar, with real-time monitoring, quick access, an empty trash button, and auto-clean configuration";
    homepage = "https://github.com/kerojiang/dms-transBin";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
