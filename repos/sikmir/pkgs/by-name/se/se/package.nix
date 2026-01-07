{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  ncurses,
}:

stdenv.mkDerivation {
  pname = "se";
  version = "3.0.1-unstable-2023-08-06";

  src = fetchFromGitHub {
    owner = "screen-editor";
    repo = "se";
    rev = "e82c110205bb1da3871e0af970533011d4573b78";
    hash = "sha256-abK8MogXh9SMSuLmj2oeBrh8tLPFqh+rKYt2CUvnw6w=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [ ncurses ];

  meta = {
    description = "screen oriented version of the classic UNIX text editor ed";
    homepage = "https://github.com/screen-editor/se";
    license = lib.licenses.publicDomain;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
