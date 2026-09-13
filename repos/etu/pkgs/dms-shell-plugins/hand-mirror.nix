{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-hand-mirror";
  version = "0-unstable-2026-06-21";

  src = fetchFromGitHub {
    owner = "hthienloc";
    repo = "dms-hand-mirror";
    rev = "d746d14f624bdd8fc00053ea0dca2b6af84fa21a";
    hash = "sha256-e1hOzZoW/juyLsQGAOQW46mGVomSEVlB57GvjegOACA=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell cozy camera preview widget with digital zoom, snapshots, and a pinnable floating window";
    homepage = "https://github.com/hthienloc/dms-hand-mirror";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
