{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  alsa-lib,
  ffmpeg,
  kdePackages,
  kdsingleapplication,
  pipewire,
  taglib,
  libebur128,
  libsndfile,
  libarchive,
  libopenmpt,
  soundtouch,
  soxr,
  libpulseaudio,
  libprojectm,
  game-music-emu,
  SDL2,
  icu,
  zlib,
  nix-update-script,
  pluginSelection ? "",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fooyin";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "fooyin";
    repo = "fooyin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HinvM2lB8CQhYNJjXt5ZVR2cw2hfVpKbtKG0BzmirCs=";
  };

  buildInputs = [
    kdePackages.qcoro
    kdePackages.qtbase
    kdePackages.qtsvg
    kdePackages.qtwayland
    taglib
    ffmpeg
    icu
    kdsingleapplication
    zlib
    alsa-lib
    pipewire
    SDL2
    libebur128
    libsndfile
    libarchive
    libopenmpt
    game-music-emu
    soundtouch
    soxr
    libpulseaudio
    libprojectm
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.qttools
    kdePackages.wrapQtAppsHook
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTING" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "INSTALL_FHS" true)
    (lib.cmakeFeature "PLUGIN_SELECTION" pluginSelection)
  ];

  env.LANG = "C.UTF-8";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Customisable music player";
    homepage = "https://www.fooyin.org/";
    changelog = "https://github.com/fooyin/fooyin/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    downloadPage = "https://github.com/fooyin/fooyin";
    mainProgram = "fooyin";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
