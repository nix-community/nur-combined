{
  lib,
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  gettext,
  blueprint-compiler,
  glib,
  python3,
  desktop-file-utils,
  gtk4,
  libadwaita
}:

stdenv.mkDerivation rec {
  pname = "upscaler";
  version = "1.2.2";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "Upscaler";
    rev = version;
    hash = "sha256-snrQ4q0DxZ0sm9uMvhU/jW0Rg8m+cLALqehL3DgTOQ4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    gettext
    blueprint-compiler
    glib
    python3
    desktop-file-utils
    gtk4
    libadwaita
  ];

  meta = with lib; {
    description = "Upscale and enhance images";
    homepage = "https://gitlab.gnome.org/World/Upscaler";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "upscaler";
    platforms = platforms.all;
  };
}
