{
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  glib,
  gtk4,
  gobject-introspection,
  vala,
  ...
}:

stdenv.mkDerivation {
  pname = "libmks";
  version = "unstable";
  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "libmks";
    rev = "90f722234b903591b86f70620040f202e51bdbc3";
    hash = "sha256-DBmaidqQSsc6X0KhAKvFagTmZuhDgw+AzQb6eSX8cSo=";
    domain = "gitlab.gnome.org";
  };

  buildInputs = [
    meson
    ninja
    pkg-config
    glib
    gtk4
    gobject-introspection
    vala
  ];

  postInstall = ''
    mkdir -p $out/bin
    cp ./tools/mks $out/bin/libmks
  '';
}
