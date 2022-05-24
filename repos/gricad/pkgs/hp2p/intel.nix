{ stdenv, lib, fetchFromGitHub, python3, python3Packages, autoconf, automake, intel-oneapi, gcc, procps } :

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
  nativeBuildInputs = [ autoconf automake python3Packages.wrapPython procps ];
  buildInputs = [ intel-oneapi gcc ] ++ (with python3Packages; [ python numpy matplotlib plotly]) ;
  pythonPath = (with python3Packages; [ numpy matplotlib plotly ]) ; 

  preConfigure = ''
    patchShebangs .
    source ${intel-oneapi}/setvars.sh
    export CFLAGS="-isystem ${stdenv.cc.cc}/include/c++/${stdenv.cc.version} -isystem ${stdenv.cc.cc}/include/c++/${stdenv.cc.version}/x86_64-unknown-linux-gnu $NIX_CFLAGS_COMPILE"
    export CFLAGS=`echo "$CFLAGS"|sed "s/isystem /I/g"`
    export CPPFLAGS="$CFLAGS"
    export LD_FLAGS="$NIX_LFLAGS"
    ./autogen.sh
    export CC=mpiicc
    export CXX=mpiicpc
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

