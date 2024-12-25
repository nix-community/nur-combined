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
  version = "0.2.0-unstable-2024-12-24";

  src = fetchFromGitLab {
    owner = "megapixels-org";
    repo = "libmegapixels";
    rev = "56f93f7a65affc20c1a668ea4e92828bc16edef3";
    hash = "sha256-iTvv8MYLO3eX9f/dUMd0YoKys05uc0cknKsU+BzkBXI=";
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
