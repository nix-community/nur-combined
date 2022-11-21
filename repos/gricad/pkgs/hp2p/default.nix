{ stdenv, lib, fetchFromGitHub, python3, python3Packages, autoconf, automake, mpi } :

stdenv.mkDerivation rec {
  pname = "hp2p";
  version = "3.4";

  src = fetchFromGitHub {
    owner = "cea-hpc";
    repo = "hp2p";
    rev = "${version}";
    sha256 = "0zvlwb941rlp3vrf9yzv7njgpj3mh4671ch7qvxfa4hq2ivd52br";
  };

  enableParallelBuilding = true;
  nativeBuildInputs = [ autoconf automake python3Packages.wrapPython ];
  buildInputs = [ mpi ] ++ (with python3Packages; [ python numpy matplotlib plotly]) ;
  pythonPath = (with python3Packages; [ numpy matplotlib plotly ]) ; 

  preConfigure = ''
    patchShebangs .
    ./autogen.sh
    export CC=mpicc
    export CXX=mpic++
  '';               

  postInstall = ''    
    wrapPythonPrograms
  '';                 

  meta = with lib; {
    description = "a MPI based benchmark for network diagnostic";
    homepage = https://github.com/cea-hpc/hp2p;
    platforms = platforms.unix;
    license = licenses.cecill-c;
    maintainers = [ maintainers.bzizou ];
  };
}

