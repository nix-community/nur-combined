{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "biplanes-revival";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "regular-dev";
    repo = "biplanes-revival";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rdPcI4j84fVKNwv2OQ9gwC0X2CHlObYfSYkCMlcm4sM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
  ];

  strictDeps = true;

  env.NIX_CFLAGS_COMPILE = "-I ../deps/TimeUtils/include";

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "BiplanesRevival";
    description = "An old cellphone arcade recreated for PC";
    homepage = "https://github.com/regular-dev/biplanes-revival";
    changelog = "https://github.com/regular-dev/biplanes-revival/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
