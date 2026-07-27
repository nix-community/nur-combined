{
  sources,

  lib,
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
stdenv.mkDerivation rec {
  inherit (sources.nyan-doom) pname src;
  version = lib.removePrefix "v" sources.nyan-doom.version;
  sourceRoot = "${src.name}/prboom2";

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

  meta = {
    description = "The most cuddly Doom Source Port, with an emphasis on innovative and quality-of-life features";
    homepage = "https://github.com/andrikpowell/nyan-doom";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "nyan-doom";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
