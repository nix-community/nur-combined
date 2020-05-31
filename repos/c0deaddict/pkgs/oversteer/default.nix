{ stdenv
, meson
, ninja
, pkgconfig
, gettext
, fetchFromGitHub
, python3
, wrapGAppsHook
, gtk3
, glib
, gnome3
, appstream-glib
, gobject-introspection
, desktop-file-utils
}:

python3.pkgs.buildPythonApplication rec {
  pname = "overseer";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "berarma";
    repo = "oversteer";
    rev = version;
    sha256 = "0mkhsyxv1avqkfwcvxr3pwhc218cqpb0jq17g8h8swl43cjs48gi";
  };

  format = "other";

  # https://github.com/NixOS/nixpkgs/issues/56943
  strictDeps = false;

  postPatch = ''
    chmod +x scripts/meson_post_install.py
    patchShebangs scripts/meson_post_install.py
  '';

  nativeBuildInputs = [
    meson ninja gettext pkgconfig wrapGAppsHook desktop-file-utils
    appstream-glib  gobject-introspection
  ];

  buildInputs = [ gtk3 glib gnome3.adwaita-icon-theme python3 ];

  propagatedBuildInputs = with python3.pkgs; [
    pyudev pyxdg evdev pygobject3
  ];

  meta = with stdenv.lib; {
    description = "Application to configure Logitech Wheels";
    homepage = "https://github.com/berarma/oversteer";
    license = licenses.gpl3;
    maintainers = with maintainers; [ c0deaddict ];
    platforms = platforms.linux;
  };
}
