{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  vala,
  pkg-config,
  gtk4,
  vte-gtk4,
}:

stdenv.mkDerivation rec {
  pname = "lazycat-terminal";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "manateelazycat";
    repo = "lazycat-terminal";
    rev = "v${version}";
    hash = "sha256-XKXjnsQYqUV+aHruXWepBHVePFBYEJytZrkN8SgMVPQ=";
  };

  patches = [
    ./0001-Use-meson-install-lazycat-terminal.desktop-file.patch
  ];

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
  ];

  buildInputs = [
    gtk4
    vte-gtk4
  ];

  meta = {
    description = "Hackable terminal";
    homepage = "https://github.com/manateelazycat/lazycat-ter";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ wineee ];
    mainProgram = "lazycat-terminal";
    platforms = lib.platforms.all;
  };
}
