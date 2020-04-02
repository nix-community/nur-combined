{ stdenv, fetchFromGitHub, mpi, python2, python2Packages, autoconf, automake } :

stdenv.mkDerivation rec {
  pname = "hp2p";
  version = "3.3";

  src = fetchFromGitHub {
    owner = "cea-hpc";
    repo = "hp2p";
    rev = "${version}";
    sha256 = "0zvlwb941rlp3vrf9yzv7njgpj3mh4671ch7qvxfa4hq2ivd52br";
  };

  enableParallelBuilding = true;
  nativeBuildInputs = [ autoconf automake python2Packages.wrapPython ];
  buildInputs = [ mpi ] ++ (with python2Packages; [ python numpy matplotlib ]) ;

  preConfigure = ''
    patchShebangs .
    ./autogen.sh
    export CC=mpicc
    export CXX=mpic++
  '';               

  postInstall = ''    
    wrapPythonPrograms
  '';                 

  meta = with stdenv.lib; {
    description = "a MPI based benchmark for network diagnostic";
    homepage = https://github.com/cea-hpc/hp2p;
    platforms = platforms.unix;
    license = licenses.cecill-c;
    maintainers = [ maintainers.bzizou ];
  };
}

