{ lib, stdenv, fetchFromGitHub, gfortran, blas, lapack, autoreconfHook } :

stdenv.mkDerivation rec {
  pname = "gMultiwfn";
  version = "3.4.1-0";

  src = fetchFromGitHub {
    owner = "stecue";
    repo = pname;
    rev = "v${version}";
    sha256 = "1y43lhk5qrsygl6hf7bk59nskvxd5xb6k7d30mclaz5gqb0lp4hy";
  };

  nativeBuildInputs = [ gfortran autoreconfHook ];

  buildInputs = [ blas lapack ];

  meta = with lib; {
    description = "gfortran port of Multiwfn";
    homepage = "https://github.com/stecue/gMultiwfn";
    license = with licenses; [ gpl2Only ];
    maintainers = [ maintainers.sheepforce ];
    platforms = platforms.linux;
  };
}
