{
  lib,
  stdenv,
  fetchFromGitLab,
}:

stdenv.mkDerivation rec {
  pname = "aulaf87-rgb";
  version = "unstable-2025-03-11";

  src = fetchFromGitLab {
    owner = "dukzcry";
    repo = "crap";
    rev = "0b8cfa984b6247dcc81d27b9d6cf0b88ba8bb6e3";
    hash = "sha256-CqTSWLnQFQz1WYHi/cG6GxmNhfgWG+8vfB9cymtMZlo=";
    sparseCheckout = [
      "aulaf87-rgb"
    ];
  };

  setSourceRoot = ''export sourceRoot="$(echo */aulaf87-rgb)"'';
  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  meta = {
    description = "Control of Aula F87 keyboard leds";
    homepage = "https://gitlab.com/dukzcry/crap/tree/master/aulaf87-rgb";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "aulaf87-rgb";
    platforms = lib.platforms.linux;
  };
}
