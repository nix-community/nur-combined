{
  sources,

  lib,
  stdenv,

  SDL2,
  SDL2_net,
  alsa-lib,
  cmake,
  fluidsynth,
  libebur128,
  libsndfile,
  libxmp,
  ninja,
  openal-soft,
  python3,
  yyjson,
}:
stdenv.mkDerivation {
  inherit (sources.cherry-doom) pname src;
  version = lib.removePrefix "cherry-doom-" sources.cherry-doom.version;

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  buildInputs = [
    SDL2
    SDL2_net
    alsa-lib
    fluidsynth
    libebur128
    libsndfile
    libxmp
    openal-soft
    yyjson
  ];

  meta = {
    description = "Fork of Nugget Doom with more additional features";
    homepage = "https://github.com/xemonix0/Cherry-Doom";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "cherry-doom";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
