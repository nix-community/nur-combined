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
  unstableGitUpdater,
  wrapGAppsHook4,
  xorg,
  zbar,
# optional runtime dependencies, used for post-processing .dng -> .jpg
  exiftool,
  graphicsmagick,
  libraw,
}:
let
  runtimePath = lib.makeBinPath [ libraw graphicsmagick exiftool ];
in
stdenv.mkDerivation {
  pname = "megapixels-next";
  version = "2.0.0-alpha1-unstable-2025-03-20";

  src = fetchFromGitLab {
    owner = "megapixels-org";
    repo = "Megapixels";
    rev = "970f32089432c4a4bbde186816c01b7706892b08";
    hash = "sha256-8f24OPkK3KHE6pmrhv9VI8pZSwHlO4NlyucM7QF6GUs=";
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

  preFixup = ''
    gappsWrapperArgs+=(
      --suffix PATH : ${lib.escapeShellArg runtimePath}
    )
  '';

  strictDeps = true;

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "The Linux-phone camera application";
    homepage = "https://gitlab.com/megapixels-org/Megapixels";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ colinsane ];
    platforms = platforms.linux;
    mainProgram = "megapixels";
  };
}
