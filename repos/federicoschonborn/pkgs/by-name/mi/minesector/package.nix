{ lib
, stdenv
, fetchFromGitHub
, cmake
, ninja
, SDL2
, SDL2_image
, SDL2_ttf
, SDL2_mixer
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "minesector";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "grassdne";
    repo = "minesector";
    rev = finalAttrs.version;
    hash = "sha256-VMTXZ4CIk9RpE4R9shHPl0R/T7mJUKY2b8Zi0DPW0/Q=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    (SDL2.override { withStatic = true; })
    SDL2_image
    SDL2_ttf
    SDL2_mixer
  ];

  meta = with lib; {
    description = "Snazzy Minesweeper-based game built with SDL2";
    homepage = "https://github.com/grassdne/minesector";
    license = licenses.mit;
    maintainers = with maintainers; [ federicoschonborn ];
    broken = stdenv.isDarwin;
  };
})
