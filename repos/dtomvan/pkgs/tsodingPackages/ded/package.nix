{
  lib,
  stdenv,
  nix-update-script,
  fetchFromGitHub,
  SDL2,
  freetype,
  glew,
  libGL,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ded";
  version = "0-unstable-2023-07-17";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "ded";
    rev = "ea30e9d6ee1c0d52aa11f9386920b884987a6b55";
    hash = "sha256-n5rvNCAy5jVZzwPHy5CYpp3n2MTd6p8Jl0SoeixdPGU=";
  };

  patches = [ ./resources.patch ];

  buildInputs = [
    SDL2
    freetype
    glew
    libGL
  ];
  nativeBuildInputs = [ pkg-config ];

  buildPhase = ''
    substituteAllInPlace src/main.c
    substituteAllInPlace src/simple_renderer.c
    CXX=cc ./build.sh
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ded $out/bin
    cp -r fonts shaders $out
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Music Visualizer";
    homepage = "https://github.com/tsoding/musializer";
    license = lib.licenses.mit;
    mainProgram = "ded";
  };
})
