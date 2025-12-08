# STATUS:
# - it unlocks via physical keyboard
# - pressing the OSK results in... nothing (on my laptop)
#   maybe it's listening only on a single input device?
{
  cairo,
  fetchFromGitea,
  gdk-pixbuf,
  lib,
  libxcrypt,
  libxkbcommon,
  meson,
  ninja,
  pam,
  pkg-config,
  scdoc,
  stdenv,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:
stdenv.mkDerivation {
  pname = "swaylock-mobile";
  version = "1.6-unstable-2022-05-01";  #< from meson.build

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "slatian";
    repo = "swaylock-mobile";
    rev = "aa5387b822f77390afe0ca7fc8c6c2fe48b0f61c";
    hash = "sha256-4lEKkpqEVvbreZg2xxCtfUJlBZpM8ScvdDBKEY3ObDo=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];
  buildInputs = [
    cairo
    gdk-pixbuf
    libxcrypt
    libxkbcommon
    pam
    wayland
    wayland-protocols
  ];

  meta = with lib; {
    description = "Fork of swaylock for use on Linux Phones";
    homepage = "https://slatecave.net/creations/swaylock-mobile/";
    mainProgram = "swaylock";
    platforms = platforms.linux;
    maintainers = with maintainers; [ colinsane ];
  };
}
