{ stdenv, fetchgit, meson, pkg-config, cmake, glib, gtk4, gtksourceview5, libadwaita, enchant, icu, appimagekit, appstream-glib, pcre, ninja, itstool, libxml2Python, wrapGAppsHook4, python3, gtk3, desktop-file-utils, lib, ... }:
stdenv.mkDerivation rec {
  pname = "gnome-text-editor";
  version = "41.1";

  src = fetchgit {
    url = "https://gitlab.gnome.org/GNOME/${pname}";
    rev = "${version}";
    hash = "sha256-fwx9v3JktUN8fQrhGz4ynYX7rK1QWQaxxV6FS5m81HE=";
  };

  patchPhase = "patchShebangs ./build-aux/meson/postinstall.py";
  nativeBuildInputs = [ meson pkg-config cmake ninja wrapGAppsHook4 python3 ]
    ++ [ gtk3 desktop-file-utils ];
  buildInputs = [ glib gtk4 gtksourceview5 libadwaita enchant icu appimagekit ]
    ++ [ appimagekit appstream-glib pcre itstool libxml2Python ];

  meta = with lib; {
    description = "A simple text editor";
    homepage = "https://gitlab.gnome.org/GNOME/${pname}";
    license = licenses.gpl3;
    maintainers = [ maintainers.vanilla ];
    platforms = [ "x86_64-linux" ];
  };
}
