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
  version = "0.2.1-unstable-2024-12-27";

  src = fetchFromGitLab {
    owner = "megapixels-org";
    repo = "libdng";
    rev = "3ad05108a8ea3a8a8fe54da4919b27f9488b9498";
    hash = "sha256-XY5c3fean+WwN3VhWWcNOwMHnrgOU/3HH3wCHigb1qw=";
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
