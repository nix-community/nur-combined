{ lib, stdenv, token, fetchgit, requireFile, python3, perl, gfortran
, eigen, globalarrays, libxml2, blas, lapack, openmpi, openssh
} :

assert token != null;

assert blas.isILP64 == lapack.isILP64;

let
  version = "2020.2";
  rev = "2021-01-18";

  # We need to keep the deps private as it contains
  # content from private Gitlab repose, only accessible
  # to licensees
  deps = requireFile {
    url = http://www.molpro.net;
    name = "molpro-deps-${version}-${rev}.tar.gz";
    sha256 = "14bjk7jl9593i3j7v44xxfpdszc5xg74b5phkf2lqx937niscg8s";
  };

in stdenv.mkDerivation {
  pname = "molpro";
  inherit version;

  src = requireFile {
    url = http://www.molpro.net;
    name = "molpro-src-${version}-${rev}.tgz";
    sha256 = "117g7fzs9qxxam5g3dfxpavb61fm2v1n6x6cq5rq0lfc0c34b6mc";
  };

  patches = [ ./build-system.patch ];

  enableParallelBuilding = true;

  nativeBuildInputs = [ perl gfortran openssh ];

  buildInputs = [
    blas
    eigen
    globalarrays
    lapack
    libxml2
    openmpi
    python3
  ];

  configureFlags = [
    "--enable-integer8"
    "--enable-aims"
  ] ++ lib.optional blas.isILP64 "--with-lapack-int64";

  prePatch = ''
    tar xf ${deps}
  '';

  postPatch = ''
    patchShebangs dependencies/libxc/scripts/get_funcs.pl
    substituteInPlace dependencies/ppidd/configure.ac --replace /bin/pwd pwd
    substituteInPlace dependencies/ppidd/configure --replace /bin/pwd pwd
  '';

  preConfigure=''
    export CXX=mpicxx
    export CXXFLAGS=-I${eigen}/include/eigen3
    export FC=mpifort
  '';

  postInstall = ''
    echo "${token}" > $out/lib/.token
  '';

  doInstallCheck = true;

  installCheckPhase = ''
     #
     # Minimal check if installation runs properly
     #
     inp=water

     cat << EOF > $inp.inp
     basis=STO-3G
     geom = {
     3
     Angstrom
     O       0.000000  0.000000  0.000000
     H       0.758602  0.000000  0.504284
     H       0.758602  0.000000 -0.504284
     }
     HF
     EOF

     # pretend this is a writable home dir
     export HOME=$PWD
     export OMPI_MCA_rmaps_base_oversubscribe=1

     # need to specify interface or: "MPID_nem_tcp_init(373) gethostbyname failed"
     $out/bin/molpro $inp.inp

     echo "Check for sucessful run:"
     grep "RHF STATE  1.1 Energy" $inp.out
     echo "Check for correct energy:"
     grep "RHF STATE  1.1 Energy" $inp.out | grep 74.880174
  '';

  meta = with lib; {
    description = "Quantum chemistry program package";
    homepage = https://www.molpro.net;
    license = licenses.unfree;
    maintainers = [ maintainers.markuskowa ];
    platforms = [ "x86_64-linux" ];
  };
}
