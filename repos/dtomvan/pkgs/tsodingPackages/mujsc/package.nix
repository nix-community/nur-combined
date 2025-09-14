{
  lib,
  nob_h,
  buildNobPackage,
  fetchFromGitHub,
}:

buildNobPackage {
  pname = "mujsc";
  version = "0-unstable-2025-09-09";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "mujsc";
    rev = "8afb8a505d25900b013747302c55c5d88de91315";
    hash = "sha256-5LvGDMQJEipjnKu0viDwNKvFUO1SmXIQ3VcKFK5W+vo=";
  };

  postPatch = ''
    substituteInPlace nob.c \
      --replace-fail './nob.h' '${nob_h}/include/nob.h'
  '';

  outPaths = [ "build/mujsc" ];

  meta = {
    description = "MuJS Compiler";
    homepage = "https://github.com/tsoding/mujsc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "mujsc";
    platforms = lib.platforms.all;
  };
}
