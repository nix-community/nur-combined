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
  version = "0.2.2-unstable-2025-11-11";

  src = fetchFromGitLab {
    owner = "megapixels-org";
    repo = "libdng";
    rev = "438df53ee06d9f21202e0398c90a9c3bf9e86591";
    hash = "sha256-2Kwz5K37I3HnnKePyY4nKYwnGHP09vr6IThiuKd3EfQ=";
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
