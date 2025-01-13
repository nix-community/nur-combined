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
  version = "0.2.1-unstable-2025-01-07";

  src = fetchFromGitLab {
    owner = "megapixels-org";
    repo = "libdng";
    rev = "bddae68d0f74f525c4a08925a47f4ae7314f5a33";
    hash = "sha256-5HNj9difK8+biWc0QXG79vG1bUkiGN/J1SxoVvQkqXk=";
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
