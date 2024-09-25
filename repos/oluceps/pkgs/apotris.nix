{
  lib,
  stdenv,
  fetchFromGitea,
  meson,
  ninja,
  python3,
  cmake,
  pkg-config,
  xxd,
  libopus,
  libogg,
  zlib,
  SDL2,
  SDL2_mixer,
  libopenmpt,
  libXrandr,
  libXext,
  libXfixes,
  libXcursor,
  libXi,
  libXScrnSaver,
}:

stdenv.mkDerivation rec {
  pname = "apotris";
  version = "4.0.2";

  src = fetchFromGitea {
    domain = "gitea.com";
    owner = "akouzoukos";
    repo = "apotris";
    rev = "v${version}";
    hash = "sha256-w9uv7A1UIn82ORyyvT8dxWHUK9chVfJ191bnI53sANU=";
    fetchSubmodules = true;
  };

  postPatch = ''
    patchShebangs tools/bin2s.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    python3
    cmake
    pkg-config
  ];
  buildInputs = [
    xxd
    libopus
    libogg
    zlib
    SDL2_mixer
    libopenmpt
    SDL2

    libXrandr
    libXext
    libXfixes
    libXcursor
    libXi
    libXScrnSaver
  ];

  meta = {
    description = "Apotris is a block stacking game for the Gameboy Advance! It features satisfying graphics, responsive controls and a large amount of customization so that you can tailor the game to your preferences";
    homepage = "https://gitea.com/akouzoukos/apotris";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ oluceps ];
    mainProgram = "apotris";
    platforms = lib.platforms.all;
  };
}
