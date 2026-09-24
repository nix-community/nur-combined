{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-actions";
  version = "0-unstable-2026-09-23";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dms-plugins";
    rev = "e774a9756f2a50499c37a5513f28bee4ebe81d73";
    hash = "sha256-92NjKVTslsbSVJMnxV4SaL7o0vZ1/mxaKdcRJr7EoqI=";
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
