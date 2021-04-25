{ lib, stdenv, fetchFromGitHub, autoreconfHook }:

stdenv.mkDerivation rec {
  pname = "colorize";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "jessek";
    repo = "colorize";
    rev = "release-${version}";
    sha256 = "sha256-8TlY2tDE+4lqHJqDy7FnOUk/xo893rL/6s8r2X/BAOc=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  meta = with lib; {
    description = "show differences between files using color graphics";
    homepage = "https://github.com/jessek/colorize";
    license = licenses.gpl3;
    maintainers = [ maintainers.genesis ];
    platforms = platforms.all;
  };
}
