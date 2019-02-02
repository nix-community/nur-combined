{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, gtk3, json-glib, vala, wrapGAppsHook, wrapXiFrontendHook }:

stdenv.mkDerivation rec {
  name = "xi-gtk-${version}";
  version = "2018-12-28";
  
  src = fetchFromGitHub {
    owner = "eyelash";
    repo = "xi-gtk";
    rev = "58918a268e82019f9265bfbea29f07e843bf980b";
    sha256 = "0dvhj4yfkmsks5k3lvrzian2a3xv8ci73d3j8iiy78clm6h0sl4a";
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
