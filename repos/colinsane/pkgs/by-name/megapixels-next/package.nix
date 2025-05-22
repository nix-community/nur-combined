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
  version = "2.0.0-alpha1-unstable-2025-05-16";

  src = fetchFromGitLab {
    owner = "megapixels-org";
    repo = "Megapixels";
    rev = "b4b0a6123066557d9c871bc138c24b2eb9474c2f";
    hash = "sha256-zzQPn9qzpXFEJZqLGhmuNbhTmiDj5SDKKXIpdxJAm08=";
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
