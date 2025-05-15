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
    hash = "sha256-BD+Sbiv88xQPOmFCs4uUOcjhHGElPayicZ3bn0wcIOg=";
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
