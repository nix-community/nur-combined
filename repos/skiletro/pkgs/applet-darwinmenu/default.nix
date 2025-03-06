{
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  name = "applet-darwinmenu";
  version = "0.9.1";
  dontConfigure = true;

  src = fetchzip {
    url = "https://github.com/Latgardi/darwinmenu/releases/download/v${version}/darwinmenu-${version}.plasmoid";
    sha256 = "sha256-9NA8FW08atejZ3Ew5fWA4IMpJSDvbmhWLqAZ1wg9cTg=";
    stripRoot = false;
    extension = "zip";
  };
  
  installPhase = ''
    mkdir -p $out/share/plasma/plasmoids
    cp -r $src/package $out/share/plasma/plasmoids/org.latgardi.darwinmenu
  '';
  
  meta.description = "Darwin menu is a Plasma applet that provides a menu system similar to that found on other operating systems.";
}
