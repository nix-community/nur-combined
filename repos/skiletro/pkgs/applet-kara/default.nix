{
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  name = "applet-kara";
  version = "0.7.3";
  dontConfigure = true;

  src = fetchzip {
    url = "https://github.com/dhruv8sh/kara/archive/refs/tags/v${version}.zip";
    sha256 = "sha256-zp6ia722gQfnUP9yd6SAYd5ga/35tjXXiudZg98xsvA=";
    stripRoot = false;
  };
  
  installPhase = ''
    mkdir -p $out/share/plasma/plasmoids
    cp -r $src/kara-${version} $out/share/plasma/plasmoids/org.dhruv8sh.kara
  '';
  
  meta.description = "A KDE Plasma Applet for use as a desktop/workspace pager.";
}
