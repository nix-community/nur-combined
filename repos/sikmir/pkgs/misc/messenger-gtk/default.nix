{ lib, stdenv, fetchurl, cmake, meson, ninja, pkg-config, desktop-file-utils, desktopToDarwinBundle
, gnunet, gst_all_1, gtk3, libgcrypt, libgnunetchat, libhandy, libnotify, libsodium, qrencode
}:

stdenv.mkDerivation rec {
  pname = "messenger-gtk";
  version = "0.8.0";

  src = fetchurl {
    url = "mirror://gnu/gnunet/messenger-gtk-${version}.tar.xz";
    hash = "sha256-Udw1thBu3cBql5KJthC+fTGwx07bvOfEFKLyyK1rtUs=";
  };

  nativeBuildInputs = [
    meson
    cmake
    ninja
    pkg-config
    desktop-file-utils # for update-desktop-database
  ] ++ lib.optional stdenv.isDarwin desktopToDarwinBundle;

  buildInputs = [
    gnunet
    gst_all_1.gstreamer
    gtk3
    libgcrypt
    libgnunetchat
    libhandy
    libnotify
    libsodium
    qrencode
  ];

  meta = with lib; {
    description = "A GTK based GUI for the Messenger service of GNUnet";
    homepage = "https://www.gnunet.org/";
    changelog = "https://git.gnunet.org/messenger-gtk.git/tree/ChangeLog?h=v${version}";
    license = licenses.agpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
