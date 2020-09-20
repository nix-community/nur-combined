{ stdenv, meson, ninja, pkg-config, gettext, fetchFromGitLab
, python3, libhandy, libpwquality
, wrapGAppsHook, gtk3, glib, gobject-introspection
, desktop-file-utils, appstream-glib, gnome3 }:

python3.pkgs.buildPythonApplication rec {
  pname = "passwordsafe";
  version = "3.99.2";

  format = "other";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "PasswordSafe";
    rev = version;
    sha256 = "0pi2l4gwf8paxm858mxrcsk5nr0c0zw5ycax40mghndb6b1qmmhf";
  };

  nativeBuildInputs = [
    meson
    ninja
    gettext
    pkg-config
    wrapGAppsHook
    desktop-file-utils
    appstream-glib
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    glib
    gnome3.adwaita-icon-theme
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pygobject3
    libkeepass

    (pykeepass.overridePythonAttrs (old: rec {
      version = "3.2.0";
      src = fetchPypi {
        pname = "pykeepass";
        inherit version;
        sha256 = "1ysjn92bixq8wkwhlbhrjj9z0h80qnlnj7ks5478ndkzdw5gxvm1";
      };
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ pycryptodome ];
    }))

  ] ++ [
    libhandy
    libpwquality
    gobject-introspection
  ];

  meta = with stdenv.lib; {
    description = "Password manager for GNOME which makes use of the KeePass v.4 format";
    homepage = "https://gitlab.gnome.org/World/PasswordSafe";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ mvnetbiz ];
  };
}

