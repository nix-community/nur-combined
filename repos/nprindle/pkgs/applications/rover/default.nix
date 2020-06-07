{ stdenv
, fetchFromGitHub
, ncurses
}:

stdenv.mkDerivation rec {
  name = "rover";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "lecram";
    repo = name;
    rev = "v${version}";
    sha256 = "00bd9j0wi36szq1zs3gqpljgznn39qh3d1yyqx25vx81jcvp357c";
  };

  outputs = [ "out" "man" ];
  buildInputs = [ ncurses ];
  makeFlags = [
    "PREFIX=$(out)"
    "MANPREFIX=$(man)/share/man"
  ];
}
