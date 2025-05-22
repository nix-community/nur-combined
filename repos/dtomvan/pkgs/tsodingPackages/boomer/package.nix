# adapted from source repo
{
  buildNimPackage,
  nix-update-script,
  lib,
  fetchFromGitHub,
  autoPatchelfHook,
  nim-1_0,
  libGL,
  xorg,
}:
buildNimPackage (finalAttrs: {
  pname = "boomer";
  version = "0-unstable-2024-02-08";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "boomer";
    rev = "dfd4e1f5514e2a9d7c7a6429c1c0642c2021e792";
    hash = "sha256-o65/VVxttriA5Qqt35lLKkWIZYS7T4VBBuYdAIGUmx8=";
  };

  lockFile = ./lock.json;

  buildInputs = [
    xorg.libX11
    xorg.libXrandr
    libGL
  ];

  nativeBuildInputs = [
    autoPatchelfHook

    nim-1_0
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
