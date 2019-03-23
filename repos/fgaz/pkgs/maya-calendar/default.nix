{ stdenv, fetchFromGitHub
, meson, ninja, vala_0_40, pkgconfig, wrapGAppsHook
, gtk3
, libchamplain
#, libchamplain-gtk
, clutter
, evolution-data-server # for libecal
#, libedataserveru
, geoclue2
, gnome3
, pantheon
, libical
, libnotify
, python3 }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "maya-calendar";
  version = "5.0";
  src = fetchFromGitHub {
    owner = "elementary";
    repo = "calendar";
    rev = version;
    sha256 = "0yiis5ig98gjw4s2qh8lppkdmv1cgi6qchxqncsjdki7yxyyni35";
  };

  nativeBuildInputs = [ meson ninja vala_0_40 pkgconfig wrapGAppsHook python3 ];
  buildInputs = [ gtk3
 libchamplain
# libchamplain-gtk
 clutter
 evolution-data-server
# libedataserveru
 geoclue2
 gnome3.folks
 gnome3.libgee
 gnome3.geocode-glib
 gnome3.glib
 gnome3.gsettings-desktop-schemas
 pantheon.granite
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

