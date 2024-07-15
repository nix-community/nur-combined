{ stdenv
, feedbackd
, fetchFromGitLab
, gtk4
, lib
, libdng
, libepoxy
, libmegapixels
, libpulseaudio
, meson
, ninja
, pkg-config
, wrapGAppsHook4
, xorg
, zbar
}:
stdenv.mkDerivation {
  pname = "megapixels-next";
  version = "unstable-2024-05-11";

  src = fetchFromGitLab {
    owner = "megapixels-org";
    repo = "Megapixels";
    rev = "ac80896c0cdc1b21882b86aeec30380463391858";
    hash = "sha256-7H6g9jDE34mGW4cSDzyVkayuyqw28x4hyumfMoF7VdQ=";
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
