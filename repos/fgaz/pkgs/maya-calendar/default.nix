{ stdenv, fetchFromGitHub
, meson, ninja, vala_0_40, pkgconfig, wrapGAppsHook
, gtk3
, libchamplain
#, libchamplain-gtk
, clutter
, evolution-data-server # for libecal
#, libedataserveru
, gnome3
, granite
, libical
, libnotify }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "maya-calendar";
  version = "unstable";
  src = fetchFromGitHub {
    owner = "elementary";
    repo = "calendar";
    rev = "dcd02192154f7cc98d28a28f480e56b05372075d";
    sha256 = "14jj3hwx1yya7hbpg00rwhglxqqand0i9dv016wkqs66c2r8jhqk";
  };

  nativeBuildInputs = [ meson ninja vala_0_40 pkgconfig wrapGAppsHook ];
  buildInputs = [ gtk3
 libchamplain
# libchamplain-gtk
 clutter
 evolution-data-server
# libedataserveru
 gnome3.folks
 gnome3.libgee
 gnome3.geocode-glib
 gnome3.glib
 gnome3.gsettings-desktop-schemas
 granite
 libical
 libnotify ];
  configurePhase = "meson build --prefix=$out";
  buildPhase = ''
    cd build
    ninja
  '';
  installPhase = "ninja install";
  meta.broken = true;
}

