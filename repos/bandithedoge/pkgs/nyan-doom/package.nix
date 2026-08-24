{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  SDL2,
  SDL2_image,
  SDL2_mixer,
  cmake,
  fluidsynth,
  libGLU,
  libmad,
  libopenmpt,
  libsndfile,
  libvorbis,
  libzip,
  ninja,
  portmidi,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nyan-doom";
  version = "1.5.4";
  src = fetchFromGitHub {
    owner = "andrikpowell";
    repo = "nyan-doom";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xo63dxtKNNyjAc7GXismXt2jtKcQgAIB5Sn1n311sJY=";
  };
  sourceRoot = "source/prboom2";

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    fluidsynth
    libGLU
    libmad
    libopenmpt
    libsndfile
    libvorbis
    libzip
    portmidi
    zlib
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "The most cuddly Doom Source Port, with an emphasis on innovative and quality-of-life features";
    homepage = "https://github.com/andrikpowell/nyan-doom";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "nyan-doom";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
