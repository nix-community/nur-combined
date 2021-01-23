{ stdenv
, fetchFromGitLab
, fetchzip

, cereal
, cmake
, git
, libGL
, libX11
, libinput
, libxkbcommon
, mesa
, meson
, ninja
, pixman
, pkg-config
, tl-expected
, wayland
, wayland-protocols
, wlroots
, xwayland
}:

stdenv.mkDerivation rec {
  pname = "cardboard";
  version = "20210120";

  src = fetchFromGitLab {
    owner = "cardboardwm";
    repo = "cardboard";
    rev = "7b15613e6e1222a6a83d69a2e5da2810dfb45522";
    sha256 = "sha256-uL7zG2Q2tnGicWBeXgNjWK/drz2bbmbb5Z69sClYmhA=";
  };

  patches = [
    ./0001-use-system-dependencies.patch
  ];

  # CMake likes to own the configurePhase, but we only need it for dependency
  # discovery. Remove it.
  configurePhase = "mesonConfigurePhase";

  nativeBuildInputs = [
    cmake
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    cereal
    libGL
    libX11
    libinput
    libxkbcommon
    pixman
    tl-expected
    wayland
    wayland-protocols
    wlroots
  ];

  passthru.providedSessions = [ "cardboard" ];

  meta = {
    description = "Scrollable tiling Wayland compositor designed with laptops in mind";
    homepage = "https://gitlab.com/cardboardwm/cardboard";
    license = stdenv.lib.licenses.gpl3;
    platforms = wlroots.meta.platforms;
  };
}
