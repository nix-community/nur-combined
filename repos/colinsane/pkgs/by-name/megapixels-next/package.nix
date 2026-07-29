{
  stdenv,
  feedbackd,
  fetchFromGitLab,
  gperf,
  gtk4,
  lib,
  libdng,
  libepoxy,
  libmegapixels,
  libpulseaudio,
  libXrandr,
  meson,
  ninja,
  pkg-config,
  unstableGitUpdater,
  wrapGAppsHook4,
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
  version = "2.1.0-unstable-2026-07-27";

  src = fetchFromGitLab {
    owner = "megapixels-org";
    repo = "Megapixels";
    rev = "578b1474e1c58829874c1a2c06844d34c9c82c56";
    hash = "sha256-J508MnwR7EaO6AwUSzoUxBychjgRRisgf8y1TgL06RQ=";
  };

  nativeBuildInputs = [
    gperf
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
    libXrandr
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

  meta = {
    description = "The Linux-phone camera application";
    homepage = "https://gitlab.com/megapixels-org/Megapixels";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux;
    mainProgram = "megapixels";
  };
}
