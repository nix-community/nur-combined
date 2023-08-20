/*
nix-build -E 'with import <nixpkgs> { }; callPackage ./gaupol.nix { }'
./result/bin/gaupol
*/

/*
based on
https://github.com/NixOS/nixpkgs/blob/master/pkgs/desktops/gnome/core/totem/default.nix
https://discourse.nixos.org/t/how-to-provide-gstreamer-to-a-python-gtk-application/16814/4
*/

{ lib
, fetchFromGitHub
, gtk3
, wrapGAppsHook
, gdk-pixbuf
, gobject-introspection
, gettext
, gst_all_1
, gspell
, isocodes
, intltool
, python3
, buildPythonPackage
, pygobject3
, chardet
}:

buildPythonPackage rec {
  pname = "gaupol";
  version = "1.10.1.20220221";
  src = fetchFromGitHub {
    owner = "otsaloma";
    repo = "gaupol";
    rev = "5415ecf12b46c2d61259b066104141938eb6e2b3";
    sha256 = "hYnIwQjs3HBwOAurBZNFyJ7oXFRkrFcgc96tZNVpUk0=";
  };
  propagatedBuildInputs = [
    pygobject3 # gi
    gdk-pixbuf # Gdk
    gobject-introspection
  ];
  buildInputs = [
    gtk3 # Pango
    gobject-introspection # Pango

    # optional
    gspell
    isocodes
    chardet
    #python3Packages.distutils_extra

    # optional: internal video player
    gst_all_1.gstreamer
    #gst_all_1.gstreamer.dev # gst-inspect
    gst_all_1.gst-plugins-base # playbin
    (gst_all_1.gst-plugins-good.override { gtkSupport = true; }) # gtksink
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];
  nativeBuildInputs = [
    gettext # msgfmt
    wrapGAppsHook
    gobject-introspection
    #intltool
  ];
  postInstall = ''
    cat >>$out/${python3.sitePackages}/aeidon/paths.py <<EOF
    DATA_DIR = '$out/share/gaupol'
    LOCALE_DIR = '$out/share/locale'
    EOF
  '';
  doCheck = false; # tests are failing: Unable to init server: Could not connect: Connection refused
  meta = with lib; {
    homepage = "https://github.com/otsaloma/gaupol";
    description = "subtitles editor in python";
    #maintainers = teams.gnome.members;
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
