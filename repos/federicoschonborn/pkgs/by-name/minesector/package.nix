{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  SDL2 ? null,
  SDL2_classic ? null,
  SDL2_image,
  SDL2_ttf,
  SDL2_mixer,
  nix-update-script,
}:

let
  SDL2' = if SDL2_classic != null then SDL2_classic else SDL2;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "minesector";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "grassdne";
    repo = "minesector";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-VMTXZ4CIk9RpE4R9shHPl0R/T7mJUKY2b8Zi0DPW0/Q=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    (SDL2'.override { withStatic = true; })
    SDL2_image
    SDL2_ttf
    SDL2_mixer
  ];

  strictDeps = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "minesector";
    description = "Snazzy Minesweeper-based game built with SDL2";
    homepage = "https://github.com/grassdne/minesector";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
