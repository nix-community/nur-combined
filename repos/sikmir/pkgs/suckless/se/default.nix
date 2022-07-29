{ lib, stdenv, fetchFromGitHub, autoreconfHook, ncurses }:

stdenv.mkDerivation rec {
  pname = "se";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "screen-editor";
    repo = "se";
    rev = "se-${version}";
    hash = "sha256-2LyYZXaL/Q3G/StCUiY6MUXG55g2YQvkpoF/lcsifD8=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [ ncurses ];

  meta = with lib; {
    description = "screen oriented version of the classic UNIX text editor ed";
    inherit (src.meta) homepage;
    license = licenses.publicDomain;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
