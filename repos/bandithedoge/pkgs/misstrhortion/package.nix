{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  cmake,
  libGL,
  libx11,
  ninja,
  pkg-config,
}:
stdenv.mkDerivation {
  pname = "misstrhortion";
  version = "0-unstable-2025-04-02";
  src = fetchFromGitHub {
    owner = "bandithedoge";
    repo = "misstrhortion";
    rev = "85fdcf6e994e018778b0d55aa987bd94c9e09f9d";
    hash = "sha256-iUo3zduI6TCqY8ju8Xs+Y0z7V26aXIfUYziakoDOeSg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    libGL
    libx11
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "DPF port of Misstortion";
    homepage = "https://github.com/bandithedoge/misstrhortion";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "Misstrhortion";
  };
}
