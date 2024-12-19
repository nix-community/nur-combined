{
  stdenv,
  fetchFromGitLab,
  lib,
  libconfig,
  meson,
  ninja,
  pkg-config,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "libmegapixels";
  version = "0.1.0-unstable-2024-12-11";

  src = fetchFromGitLab {
    owner = "megapixels-org";
    repo = "libmegapixels";
    rev = "4666a6d09e3ce0dc5ac44b1e4c7bfe3d5c5e1abf";
    hash = "sha256-OU7K/GzPDDG177/XYYPSdup9nUDLhdDtmn0dSg3UAyw=";
  };

  # patches = [
  #   (fetchpatch {
  #     name = "load_camera: initialize with `calloc` to avoid uninitialized reads";
  #     url = "https://git.uninsane.org/colin/libmegapixels/commit/dec641dc510221a50f3d30bbd1bfd82ec8d17621.patch";
  #     hash = "sha256-c8KrFDWfekk+mqf03IEynfCPd+sVyxphG/0RWSdZZqQ=";
  #   })

  #   # (fetchpatch {
  #   #   # not actually necessary: video_path is INTENDED to never be NULL (as part of initialization)
  #   #   name = "pipeline: NULL check against video_path before using it";
  #   #   url = "https://git.uninsane.org/colin/libmegapixels/commit/07afaaebc6b6bb51641dc5777d9563e337a45672.patch";
  #   #   hash = "sha256-fNJKgI6rjNdGRiO0O4Runfd72bfhjUrxu4zABKBeKNs=";
  #   # })
  # ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libconfig
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "The device abstraction for the Megapixels application";
    homepage = "https://gitlab.com/megapixels-org/libmegapixels";
    maintainers = with maintainers; [ colinsane ];
    platforms = platforms.linux;
  };
}
