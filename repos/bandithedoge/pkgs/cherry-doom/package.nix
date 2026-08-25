{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,

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
stdenv.mkDerivation (finalAttrs: {
  pname = "cherry-doom";
  version = "2.1.0";
  src = fetchFromGitHub {
    owner = "xemonix0";
    repo = "Cherry-Doom";
    rev = "cherry-doom-${finalAttrs.version}";
    fetchSubmodules = false;
    sha256 = "sha256-ixuYlr+X9xLC0xUqazuuj+ebflJf/GjSuWXK05kbtwA=";
  };

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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "cherry-doom-(.*)"
    ];
  };

  meta = {
    description = "Fork of Nugget Doom with more additional features";
    homepage = "https://github.com/xemonix0/Cherry-Doom";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "cherry-doom";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
