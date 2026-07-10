# adapted from source repo
{
  buildNimPackage,
  nix-update-script,
  lib,
  fetchFromGitHub,
  autoPatchelfHook,
  nim_1_0,
  libGL,
  libX11,
  libXrandr,
}:
buildNimPackage (finalAttrs: {
  pname = "boomer";
  version = "0-unstable-2026-05-24";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "boomer";
    rev = "97189f7ef07859a86420ef11258ca29527774d9c";
    hash = "sha256-GxrPoDU1vj0SGuji/vinRu7WThY/J7LTdIdrOG4WOwo=";
  };

  lockFile = ./lock.json;

  buildInputs = [
    libX11
    libXrandr
    libGL
  ];

  nativeBuildInputs = [
    autoPatchelfHook

    nim_1_0
  ];

  nimFlags = [
    "-d:release"
    "-d:NimblePkgVersion=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Zoomer application for Linux";
    homepage = "https://github.com/tsoding/boomer";
    license = lib.licenses.mit;
    mainProgram = "boomer";
  };
})
