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
  version = "2.1.0-unstable-2026-02-24";

  src = fetchFromGitLab {
    owner = "megapixels-org";
    repo = "Megapixels";
    rev = "51d0b970bffb3b4abcbeb8cad3c21e6b311aff26";
    hash = "sha256-3dBHw5B4pvFdkn1S8GjWEsCXqer93UlVPQtGNj8VDOw=";
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
