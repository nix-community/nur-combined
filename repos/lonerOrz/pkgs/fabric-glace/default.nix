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
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "glace";
    rev = "8c2cc2a46a3856121bec701e7c468b35416b2428";
    hash = "sha256-T5zelHwpVkQstBILujqLJimW74Mhuj5H6/kAV6IkyJQ=";
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

  passthru.updateScript = ./update.sh;

  meta = {
    description = "system glace for everyone";
    homepage = "https://github.com/your-github-username/gray";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
