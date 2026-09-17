{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  SDL2,
  SDL2_image,
  SDL2_mixer,
  cmake,
  discord-rpc,
  fluidsynth,
  libGLU,
  libmad,
  libopenmpt,
  libsndfile,
  libspng,
  libvorbis,
  libzip,
  ninja,
  portmidi,
  rapidjson,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nyan-doom";
  version = "1.6.0";
  src = fetchFromGitHub {
    owner = "andrikpowell";
    repo = "nyan-doom";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2vQz0FSE7iZwrs6K3xiuTkgBbbVVmv8WW5gFuXIU6Bw=";
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
    discord-rpc
    fluidsynth
    libGLU
    libmad
    libopenmpt
    libsndfile
    libspng
    libvorbis
    libzip
    portmidi
    rapidjson
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
