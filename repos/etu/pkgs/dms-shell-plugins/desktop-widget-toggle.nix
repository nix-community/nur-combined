{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-desktop-widget-toggle";
  version = "0-unstable-2026-06-09";

  src = fetchFromGitHub {
    owner = "hthienloc";
    repo = "dms-desktop-widget-toggle";
    rev = "be6556d8f70e990fcc2cfa4a0125e2a1423c717c";
    hash = "sha256-XR8xzJMnPtgW4qnuKlfEJoUDgwzM7++IN7KKauhdZ+k=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget to toggle visibility of desktop widget groups as an overlay";
    homepage = "https://github.com/hthienloc/dms-desktop-widget-toggle";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
