{
  lib,
  stdenv,
  fetchFromGitLab,
  wayland,
  libglvnd,
  libbsd,
  libunwind,
  libelf,
  meson,
  pkg-config,
  ninja,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bionic-translation";
  version = "6253dec";

  src = fetchFromGitLab {
    owner = "android_translation_layer";
    repo = "bionic_translation";
    rev = finalAttrs.version;
    hash = "sha256-iEQfxPXsyC6YwAhPiRT/qrU54LMlD3sdoW2O1R/cugA=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libbsd
    libelf
    libglvnd
    libunwind
    wayland
  ];

  meta = {
    description = "Set of libraries for loading bionic-linked .so files on musl/glibc";
    homepage = "https://gitlab.com/android_translation_layer/bionic_translation";
    # No license specified yet
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ onny ];
  };
})
