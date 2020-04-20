{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "sbase";
  version = "unstable-2020-04-15";

  src = fetchgit {
    url = "git://git.suckless.org/${pname}";
    rev = "92f17ad648114ce6bf967d890053d5b6b8504c28";
    sha256 = "0y1nisyn9h8gmrcp9422yyqa1mw8gzk6i00k94f2vs09s98h17vd";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "suckless unix tools";
    license = licenses.mit;
    maintainers = with maintainers; [ joshuafern ];
  };
}
