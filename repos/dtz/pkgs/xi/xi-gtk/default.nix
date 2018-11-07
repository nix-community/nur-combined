{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, gtk3, json-glib, vala, wrapGAppsHook, wrapXiFrontendHook }:

stdenv.mkDerivation rec {
  name = "xi-gtk-${version}";
  version = "2018-10-30";
  
  src = fetchFromGitHub {
    owner = "eyelash";
    repo = "xi-gtk";
    rev = "e208321f54d5ca2263c281984f6bb7395aa6f2e3";
    sha256 = "154i8f3dxn5p6m18jxid407i3m260y4317dgzq831wagmg7y6wxg";
  };

  nativeBuildInputs = [ meson ninja pkgconfig ];

  buildInputs = [
    gtk3 json-glib vala
    wrapGAppsHook
    wrapXiFrontendHook
  ];

  postInstall = "wrapXiFrontend $out/bin/*";

  meta = with stdenv.lib; {
    description = "A GTK+ front-end for the Xi editor";
    homepage = https://github.com/eyelash/xi-gtk;
    license = licenses.asl20;
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}
