{
  stdenv,
  fetchFromGitLab,
  lib,
  libtiff,
  meson,
  ninja,
  pkg-config,
  scdoc,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "libdng";
  version = "0.2.0-unstable-2024-12-24";

  src = fetchFromGitLab {
    owner = "megapixels-org";
    repo = "libdng";
    rev = "228b16daeb3a515188bf919322132e03dc5a84ee";
    hash = "sha256-ZqXqK0QighD844hcgkTvYVgTtD2xAxE9lUsIIEqHwcc=";
  };

  depsBuildBuild = [
    pkg-config # to find scdoc for cross builds
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
  ];

  buildInputs = [
    libtiff
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Interface library between libtiff and the world to make sure the output is valid DNG";
    homepage = "https://libdng.me.gapixels.me";
    license = licenses.mit;
    maintainers = with maintainers; [ colinsane ];
    platforms = platforms.linux;
  };
}
