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
  version = "0-unstable-2025-11-25";

  src = fetchFromGitLab {
    owner = "android_translation_layer";
    repo = "bionic_translation";
    rev = "ee37eb2";
    hash = "sha256-4wZkkCCzjWwaoC0bpeGuUcOrx0zpsZHJEV0ZC2fOi/M=";
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
