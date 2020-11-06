{ stdenv, fetchurl, autoPatchelfHook,
libstdcxx5, libX11, libXrender, libXt, libXext, glib, freetype, fontconfig,
alsaLib, dbus-glib, dbus, cairo, pango, atk, gdk_pixbuf, gnome3, gnome2, gcc49 }:

stdenv.mkDerivation {
  name = "kaiosrt";

  src = fetchurl {
    url = "https://s3.amazonaws.com/kaicloudsimulatordl/developer-portal/simulator/Kaiosrt_ubuntu.tar.bz2";
    sha256 = "1f7q7iq4azini8aa7fi697awwfrgf6lf7qmizd52w41vnvm1dxll";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
        libX11
        libXrender
        libXt
        libXext
        glib
        freetype
        fontconfig
        alsaLib
        dbus-glib
        dbus
        cairo
        pango
        atk
        gdk_pixbuf
        gnome3.gtk
        gnome2.gtk
        gcc49
  ];

  buildPhase = "";
  installPhase = ''
    tar -xf kaiosrt-v2.5.en-US.linux-x86_64.tar.bz2
    mkdir -p $out
    cp -r kaiosrt $out/bin
  '';
}
