{
  lib,
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  vala,
  glib,
  gobject-introspection,
  hidapi,
  libevdev,
  libgudev,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "libmanette-1";
  version = "0.2.12-unstable-2025-04-19";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "libmanette";
    rev = "da8ec205321d30dd9968a0e49fb007a74ce2a453";
    hash = "sha256-yq/x8pspeXBYb08u4beKZ2xKXd/3HfSgJeTHkJ+oAto=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    hidapi
    libevdev
    libgudev
  ];

  strictDeps = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "";
    homepage = "https://gitlab.gnome.org/GNOME/libmanette";
    changelog = "https://gitlab.gnome.org/GNOME/libmanette/-/blob/${src.rev}/NEWS";
    license = lib.licenses.lgpl21Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
