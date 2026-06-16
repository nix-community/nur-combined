{
  lib,
  stdenv,
  fetchFromGitHub,
  gobject-introspection,
  meson,
  pkg-config,
  ninja,
  vala,
  wayland-scanner,
  glib,
  gtk3,
}:

stdenv.mkDerivation {
  pname = "fabric-glace";
  version = "0-unstable-2026-06-16";

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "glace";
    rev = "363715931c6895b241e298d0e4a6b46635dff370";
    hash = "sha256-w03k77DbCjKOC2EJEAm8kXV1KID5t9G88a6Co8OLFxc=";
  };

  nativeBuildInputs = [
    gobject-introspection
    meson
    pkg-config
    ninja
    vala
    wayland-scanner
  ];

  buildInputs = [
    glib
    gtk3
  ];

  outputs = [
    "out"
    "dev"
  ];

  passthru.updateArgs = [ "--version=branch" ];

  meta = {
    description = "system glace for everyone";
    homepage = "https://github.com/your-github-username/gray";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
