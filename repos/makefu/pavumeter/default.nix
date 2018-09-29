{ lib, stdenv,  fetchurl, libusb, libtool, autoconf, pkgconfig, git,
gettext, automake, libxml2 
, autoreconfHook
, lynx
, gtkmm2
, libpulseaudio
, gnome2
, libsigcxx
}:
stdenv.mkDerivation rec {
  pname = "pavumeter";
  name = "${pname}-${version}";
  version = "0.9.3";

  src = fetchurl {
    url = "http://0pointer.de/lennart/projects/${pname}/${name}.tar.gz";
    sha256 = "0yq67w8j8l1xsv8pp37bylax22npd6msbavr6pb25yvyq825i3gx";
  };

  buildInputs = [ gtkmm2 libpulseaudio gnome2.gnome_icon_theme ];
  nativeBuildInputs = [ pkgconfig autoreconfHook lynx ];

  meta = {
    description = "PulseAudio volumene meter";
    homepage = http://0pointer.de/lennart/projects/pavumeter;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ makefu ];
  };
}
