{ lib
, stdenv
, fetchFromGitLab
, desktop-file-utils
, meson
, ninja
, pkg-config
, vala
, wrapGAppsHook4
, libadwaita
, libgee
, libhighscore
, libmanette
, libpulseaudio
, SDL2
}:

stdenv.mkDerivation {
  pname = "highscore2";
  version = "unstable-2023-09-03";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "alicem";
    repo = "highscore2";
    rev = "c1b236a2c45ca10804167b215d549bd9bfb145ba";
    hash = "sha256-n3D+vZ0Ke47/vd+p6J3+fW/+iG65dwME2DCz3YGTiMk=";
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
    libadwaita
    libgee
    libhighscore
    libmanette
    libpulseaudio
    SDL2
  ];

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/alicem/highscore2";
    mainProgram = "highscore";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}
