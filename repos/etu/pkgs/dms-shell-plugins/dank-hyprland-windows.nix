{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-hyprland-windows";
  version = "0-unstable-2026-09-23";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dms-plugins";
    rev = "e774a9756f2a50499c37a5513f28bee4ebe81d73";
    hash = "sha256-92NjKVTslsbSVJMnxV4SaL7o0vZ1/mxaKdcRJr7EoqI=";
  };

  sourceRoot = "source/DankHyprlandWindows";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell launcher plugin to switch between Hyprland windows with live previews";
    homepage = "https://github.com/AvengeMedia/dms-plugins";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
