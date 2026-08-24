{
  fetchFromGitHub,

  lib,
  stdenv,
  ninja,
  cmake,
  libsndfile,
  flex,
  bison,
  alsa-lib,
}:
stdenv.mkDerivation {
  pname = "csound6";
  version = "6.18.1";
  src = fetchFromGitHub {
    owner = "csound";
    repo = "csound";
    rev = "6.18.1";
    hash = "sha256-O7s92N54+zIl07eIdK/puoSve/qJ3O01fTh0TP+VdZA=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    flex
    bison
  ];

  buildInputs = [
    libsndfile
    alsa-lib
  ];

  NIX_CFLAGS_COMPILE = [ "-Wno-template-body" ];

  meta = {
    description = "Sound design, audio synthesis, and signal processing system, providing facilities for music composition and performance on all major operating systems and platforms";
    homepage = "https://csound.com";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
    mainProgram = "csound";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
