{ lib
, stdenv

  # Dependencies
, gtk4
}:

let
  inherit (lib) getExe';
in
stdenv.mkDerivation {
  inherit (gtk4) version;

  pname = "gtk4-icon-browser";

  dontUnpack = true;

  installPhase = ''
    mkdir --parents $out/bin
    ln --symbolic ${getExe' gtk4.dev "gtk4-icon-browser"} $out/bin/

    mkdir --parents $out/share/applications
    ln --symbolic ${gtk4}/share/applications/org.gtk.IconBrowser4.desktop $out/share/applications/

    mkdir --parents $out/share/icons/hicolor/scalable/apps
    ln --symbolic ${gtk4}/share/icons/hicolor/scalable/apps/org.gtk.IconBrowser4.svg $out/share/icons/hicolor/scalable/apps/

    mkdir --parents $out/share/icons/hicolor/symbolic/apps
    ln --symbolic ${gtk4}/share/icons/hicolor/symbolic/apps/org.gtk.IconBrowser4-symbolic.svg $out/share/icons/hicolor/symbolic/apps/

    mkdir --parents $out/share/metainfo
    ln --symbolic ${gtk4}/share/metainfo/org.gtk.IconBrowser4.appdata.xml $out/share/metainfo/
  '';

  meta = {
    inherit (gtk4.meta) license;

    description = "Browse the icons that are available in the icon theme";
    homepage = "https://wiki.gnome.org/Projects/GTK/IconBrowser";
  };
}
