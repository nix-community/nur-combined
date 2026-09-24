{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-hooks";
  version = "0-unstable-2026-09-23";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dms-plugins";
    rev = "e774a9756f2a50499c37a5513f28bee4ebe81d73";
    hash = "sha256-92NjKVTslsbSVJMnxV4SaL7o0vZ1/mxaKdcRJr7EoqI=";
  };

  sourceRoot = "source/DankHooks";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell daemon plugin to execute custom scripts on system events like wallpaper changes, theme updates, and battery level changes";
    homepage = "https://github.com/AvengeMedia/dms-plugins";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
