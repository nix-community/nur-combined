{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-hyprland-windows";
  version = "0-unstable-2026-09-08";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dms-plugins";
    rev = "6fc7f25bfb24f93b6488fb8a36ed67b5f242abdb";
    hash = "sha256-KGpNgxN/zXiMjLLm4zLX+Wgnj1vx8bGGd6WwGBWo7Ds=";
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
