{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-todo";
  version = "0-unstable-2026-06-29";

  src = fetchFromGitHub {
    owner = "deepu105";
    repo = "dms-dank-todo";
    rev = "ff1b82c3061fce3c32c8f65792fa81b928ab35d1";
    hash = "sha256-zX9rtJwq5KyXHG55bQXbV7osAMHTkL9l7qSRqEgh6kI=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell simple locally-saved TODO list widget for the DankBar";
    homepage = "https://github.com/deepu105/dms-dank-todo";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
