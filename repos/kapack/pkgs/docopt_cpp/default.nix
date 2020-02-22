{ stdenv, fetchgit, cmake, python2 }:

stdenv.mkDerivation rec {
  pname = "docopt.cpp";
  version = "0.6.2";

  src = fetchgit {
    url = "https://github.com/mpoquet/docopt.cpp.git";
    rev = "3394186f2951d3c7de3745b8c12dd930fe858768";
    sha256 = "0danwzs19fzyvd0z3v8zy6m9f34sdshr6dqg2fkrs9wgdsf6wycx";
  };

  nativeBuildInputs = [ cmake python2 ];

  cmakeFlags = ["-DWITH_TESTS=ON"];

  doCheck = true;

  checkPhase = "LD_LIBRARY_PATH=$(pwd) python2 ./run_tests";

  meta = with stdenv.lib; {
    description = "C++11 port of docopt";
    longDescription = ''A C++11 port of docopt, a library to define command-line interfaces.'';
    homepage = https://github.com/docopt/docopt.cpp;
    license = with licenses; [ mit boost ];
    broken = false;
    platforms = platforms.all;
    maintainers = with maintainers; [ knedlsepp ];
  };
}
