{ stdenv
, lib
, gettext
, libxml2
, libhandy
, fetchurl
, fetchpatch
, pkg-config
, libcanberra-gtk3
, gtk3
, glib
, meson
, ninja
, python3
, wrapGAppsHook
, appstream-glib
, desktop-file-utils
, gnome
, gsettings-desktop-schemas
}:

stdenv.mkDerivation rec {
  pname = "gnome-screenshot";
  version = "41.0";

  src = fetchurl {
    url = "https://gitlab.gnome.org/mipmip/gnome-screenshot/-/archive/master/gnome-screenshot-master.tar.gz";
    sha256 = "MwB3axXkIgxNOEUYisKDWcFodAAzZ9H+NsU4nAwU31A=";
  };

  patches = [
    # Fix build with meson 0.61
    # https://gitlab.gnome.org/GNOME/gnome-screenshot/-/issues/186
    (fetchpatch {
      url = "https://gitlab.gnome.org/GNOME/gnome-screenshot/-/commit/b60dad3c2536c17bd201f74ad8e40eb74385ed9f.patch";
      sha256 = "Js83h/3xxcw2hsgjzGa5lAYFXVrt6MPhXOTh5dZTx/w=";
    })

#    (fetchpatch {
#      url = "https://gitlab.gnome.org/mipmip/gnome-screenshot/-/commit/05975ee88bed6108b2baa46d1b2070ae71ad3e4e.patch";
#      sha256 = "3tod1EBVzzo44gZt0r4Bp6gsnvy7r28+0X4zXe4bcWE=";
#    })

  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    appstream-glib
    libxml2
    desktop-file-utils
    python3
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3
    glib
    libcanberra-gtk3
    libhandy
    gnome.adwaita-icon-theme
    gsettings-desktop-schemas
  ];

  doCheck = true;

  postPatch = ''
    chmod +x build-aux/postinstall.py # patchShebangs requires executable file
    patchShebangs build-aux/postinstall.py
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      attrPath = "gnome.${pname}";
    };
  };

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/GNOME/gnome-screenshot";
    description = "Utility used in the GNOME desktop environment for taking screenshots";
    maintainers = teams.gnome.members;
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
