{ lib, stdenv, fetchFromGitLab, meson, pkgconfig, glib, libvirt, libvirt-glib
, docutils, ninja }:

stdenv.mkDerivation rec {
  pname = "libvirt-dbus";
  version = "1.4.1";

  src = fetchFromGitLab {
    owner = "libvirt";
    repo = "libvirt-dbus";
    rev = "v${version}";
    sha256 = "sha256:112jbkp2b0pk6dpb0p68zg1ba196f4i0y57s1jzjn5vl4f11fv3g";
  };

  mesonFlags = [
    "-Dsystem_user=root"
  ];

  nativeBuildInputs = [
    meson pkgconfig docutils ninja
  ];
  buildInputs = [
    glib libvirt libvirt-glib
  ];

  meta = with lib; {
    description = "DBus protocol binding for libvirt native C API";
    license = licenses.lgpl2Plus;
    homepage = src.meta.homepage;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
