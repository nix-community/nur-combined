{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation {
  name = "gtk-v4l";
  version = "0.4";
  src = ./gtk-v4l-0.4.tar.gz;
  nativeBuildInputs = [ autoreconfHook gtk3-x11 glib pkgconfig libv4l gnome3.libgudev ];
  patches = [ ./am_prog_ar.diff ./gtk-v4l-0.4-device-remove-source-on-finalize.patch ];
  NIX_CFLAGS_COMPILE = [ "-Wno-error=format-truncation" "-Wno-error=deprecated-declarations" "-Wno-error=format-security" ];

  meta = {
    description = "GUI for adjusting settings of V4L devices";
    license = stdenv.lib.licenses.gpl2;
  };
}
