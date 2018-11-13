{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, gtk3, json-glib, vala, wrapGAppsHook, wrapXiFrontendHook }:

stdenv.mkDerivation rec {
  name = "xi-gtk-${version}";
  version = "2018-11-09";
  
  src = fetchFromGitHub {
    owner = "eyelash";
    repo = "xi-gtk";
    rev = "3dbeec6569ad1e383658cb225526f413ebdd1b17";
    sha256 = "0pymczpbbzd28q8ymmkav39mhwdby0asxl5h81rnrwqlsih7dnx4";
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
