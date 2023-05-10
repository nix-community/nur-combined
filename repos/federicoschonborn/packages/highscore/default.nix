{ lib
, stdenv
, fetchFromGitLab
, desktop-file-utils
, grilo
, libadwaita
, libarchive
, libmanette
, libxml2
, meson
, ninja
, pkg-config
, retro-gtk
, sqlite
, vala
, wrapGAppsHook4
}:

stdenv.mkDerivation rec {
  pname = "highscore";
  version = "unstable-2023-04-06";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "highscore";
    rev = "c324f5f50c406615b93f29063ed97910ffe6a9ae";
    hash = "sha256-O2DCp8xmXZtU7c8XReswOSHkX65HG7BSgWrKiGWr6lg=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    grilo
    libadwaita
    libarchive
    libmanette
    libxml2
    retro-gtk
    sqlite
  ];

  meta = with lib; {
    description = "";
    homepage = "https://gitlab.gnome.org/World/highscore";
    changelog = "https://gitlab.gnome.org/World/highscore/-/blob/${src.rev}/NEWS";
    license = licenses.gpl3Only;
    # TODO
    broken = true;
  };
}
