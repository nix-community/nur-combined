{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-actions";
  version = "0-unstable-2026-10-20";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dms-plugins";
    rev = "b827c2296cd45a73bf9318f16a261c9edeec8339";
    hash = "sha256-OYCjryGkZ9DlMSS0DlaKzA/qRxXI+cAbO3uee+9Y+Kg=";
  };

  sourceRoot = "source/DankActions";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget that executes custom commands with dynamic output display and configurable icons";
    homepage = "https://github.com/AvengeMedia/dms-plugins";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
