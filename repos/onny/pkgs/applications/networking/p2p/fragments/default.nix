{ stdenv, fetchgit, meson, ninja, cmake, desktop-file-utils, automake, autoconf, libtool, libevent, openssl, zlib, pkgconfig, libgee, curl, vala, glib, python3, gtk3, libhandy, hicolor-icon-theme, wrapGAppsHook }:

stdenv.mkDerivation rec {
  pname = "fragments";
  version = "1.4";

  src = fetchgit {
    url = "https://gitlab.gnome.org/World/Fragments";
    rev = version;
    fetchSubmodules = true;
    sha256 = "1zmdm4rfvmsx03gcxaxv7j8chayi0h375ksb4mn3qzzqdi06qc7v";
  };

  nativeBuildInputs = [
    autoconf
    automake
    cmake
    desktop-file-utils
    libtool
    meson
    ninja
    pkgconfig
    python3
    vala
    wrapGAppsHook
  ];

  buildInputs = [
    curl
    glib
    gtk3
    hicolor-icon-theme
    libevent
    libgee
    libhandy
    openssl
    zlib
  ];

  patches = [ ./find_library.patch ];

  postPatch = ''
    chmod +x build-aux/*
    patchShebangs build-aux
  '';

  dontUseCmakeConfigure = true;

  meta = with stdenv.lib; {
    description = "An easy to use BitTorrent client which follows the GNOME HIG and includes well thought-out features";
    homepage = https://gitlab.gnome.org/World/Fragments;
    maintainers = with maintainers; [ worldofpeace ];
    platforms = platforms.linux;
    license = licenses.gpl3;
  };
}
