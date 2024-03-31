{ lib
, stdenv
, fetchFromGitLab
, meson
, ninja
, pkg-config
, cmake
, libadwaita
, desktop-file-utils
, help2man
, webkitgtk
, itstool
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "zenity";
  version = "4.0.1";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "zenity";
    rev = version;
    hash = "sha256-yugbJ5ZeaTFxlUfVBHE1w5hAWscUW/pjlpD75Bk2q0U=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cmake
    desktop-file-utils # desktop-file-validate
    help2man
    webkitgtk
    itstool
    wrapGAppsHook
  ];

  buildInputs = [
    libadwaita
  ];

  meta = with lib; {
    description = "";
    homepage = "https://gitlab.gnome.org/GNOME/zenity";
    changelog = "https://gitlab.gnome.org/GNOME/zenity/-/blob/${src.rev}/ChangeLog";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ ];
    mainProgram = "zenity";
    platforms = platforms.all;
  };
}
