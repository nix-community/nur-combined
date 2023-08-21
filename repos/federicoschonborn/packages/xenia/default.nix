{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, python3
, gtk3
, SDL2
}:

stdenv.mkDerivation {
  pname = "xenia";
  version = "unstable-2023-07-27";

  src = fetchFromGitHub {
    owner = "xenia-project";
    repo = "xenia";
    rev = "c5e6352c349ca65b7119bab08d19797e95eb1509";
    hash = "sha256-k7cjPvNAH08aYZFS3rMOGAXOZbt4pIIVyPhQeYIGSvU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    python3
  ];

  buildInputs = [
    gtk3
    SDL2
  ];

  postPatch = ''
    patchShebangs ./xenia-build
  '';

  buildPhase = ''
    runHook preBuild

    ./xenia-build build

    runHook postBuild
  '';

  meta = with lib; {
    description = "Xbox 360 Emulator Research Project";
    homepage = "https://github.com/xenia-project/xenia";
    license = licenses.bsd3;
    maintainers = with maintainers; [ federicoschonborn ];
    # #warning _FORTIFY_SOURCE requires compiling with optimization (-O) [-Werror=cpp]
    broken = true;
  };
}
