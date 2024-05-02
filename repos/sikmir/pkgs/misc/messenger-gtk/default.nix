{ lib
, stdenv
, fetchurl
, cmake
, meson
, ninja
, pkg-config
, desktop-file-utils
, desktopToDarwinBundle
, gnunet
, gst_all_1
, gtk3
, libgcrypt
, libgnunetchat
, libhandy
, libnotify
, libportal
, libportal-gtk3
, libsodium
, libunistring
, pipewire
, qrencode
}:

stdenv.mkDerivation rec {
  pname = "messenger-gtk";
  version = "0.9.0";

  src = fetchurl {
    url = "mirror://gnu/gnunet/messenger-gtk-${version}.tar.gz";
    hash = "sha256-DqviYQ+zEy75mQEHKi90pkDgps4gM6YrjN9esrCmi0s=";
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
    libportal
    libportal-gtk3
    libsodium
    libunistring
    pipewire
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
