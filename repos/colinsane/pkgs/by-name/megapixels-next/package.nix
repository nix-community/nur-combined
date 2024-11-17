{
  stdenv,
  feedbackd,
  fetchFromGitLab,
  gtk4,
  lib,
  libdng,
  libepoxy,
  libmegapixels,
  libpulseaudio,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
  xorg,
  zbar,
}:
stdenv.mkDerivation {
  pname = "megapixels-next";
  version = "unstable-2024-09-03";

  src = fetchFromGitLab {
    owner = "megapixels-org";
    repo = "Megapixels";
    rev = "d0e4e318c175ce6dd9c70983f4ce81fc3b7b3a91";
    hash = "sha256-qmYTQq7Zg3m7dE/8SxdDNI/kU5nwa3jPDDG7NDK1eS4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    feedbackd
    gtk4
    libdng
    libepoxy
    libmegapixels
    libpulseaudio
    xorg.libXrandr
    zbar
  ];

  postInstall = ''
    glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  strictDeps = true;

  meta = with lib; {
    description = "The Linux-phone camera application";
    homepage = "https://gitlab.com/megapixels-org/Megapixels";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ colinsane ];
    platforms = platforms.linux;
    mainProgram = "megapixels";
  };
}
