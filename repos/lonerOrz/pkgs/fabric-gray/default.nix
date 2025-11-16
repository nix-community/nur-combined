{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  libdbusmenu-gtk3,
  gtk3,
  gobject-introspection,
  meson,
  pkg-config,
  ninja,
  vala,
}:

stdenv.mkDerivation {
  pname = "fabric-gray";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "gray";
    rev = "d5a8452c39b074ef6da25be95305a22203cf230e";
    hash = "sha256-s9v9fkp+XrKqY81Z7ezxMikwcL4HHS3KvEwrrudJutw=";
  };

  nativeBuildInputs = [
    gobject-introspection
    meson
    pkg-config
    ninja
    vala
  ];

  buildInputs = [
    glib
    libdbusmenu-gtk3
    gtk3
  ];

  outputs = [
    "out"
    "dev"
  ];

  meta = {
    description = "system trays for everyone ⚡";
    homepage = "https://github.com/your-github-username/gray";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
