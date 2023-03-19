{ lib, stdenv, fetchFromGitHub, meson, ninja, pkgconfig, gtk3, json-glib, vala, wrapGAppsHook, wrapXiFrontendHook }:

stdenv.mkDerivation rec {
  name = "xi-gtk-${version}";
  version = "2020-03-29";
  
  src = fetchFromGitHub {
    owner = "eyelash";
    repo = "xi-gtk";
    rev = "753b5e083748e3bcebb199efce1ad89197b757e7";
    sha256 = "sha256-OroX26ZbbDXWs6zjiltWf0DyIdrAO7sArPDESdV0EbE=";
  };

  nativeBuildInputs = [ meson ninja pkgconfig ];

  buildInputs = [
    gtk3 json-glib vala
    wrapGAppsHook
    wrapXiFrontendHook
  ];

  postInstall = "wrapXiFrontend $out/bin/*";

  meta = with lib; {
    description = "A GTK+ front-end for the Xi editor";
    homepage = https://github.com/eyelash/xi-gtk;
    license = licenses.asl20;
    #maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}
