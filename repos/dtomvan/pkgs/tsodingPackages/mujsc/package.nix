{
  lib,
  nob_h,
  buildNobPackage,
  fetchFromGitHub,
}:

buildNobPackage {
  pname = "mujsc";
  version = "0-unstable-2025-09-20";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "mujsc";
    rev = "809be5ed478730e8b3a3a25cc793346a6c4edbbf";
    hash = "sha256-U1FiT7SoBF5HHl2NM4z4cdSVN1rJ96e6w3LwvA1vxwE=";
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
