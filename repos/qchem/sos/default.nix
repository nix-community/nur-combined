{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, rdma-core, libfabric, libnl, perl, openmpi, openssh
} :

let
  version = "1.4.0";

in stdenv.mkDerivation {
  name = "sos-${version}";

  src = fetchFromGitHub {
    owner = "Sandia-OpenSHMEM";
    repo = "SOS";
    rev = "v${version}";
    sha256 = "042zhdi2jr08jaliilkx7gmhhdlrwikkq667d2iki8q553klrn1k";
  };

  configureFlags = [
    "--enable-pmi-simple"
    "--with-cma"
    "--with-ofi=${libfabric}"
  ];

  nativeBuildInputs = [ autoconf automake libtool openmpi openssh ];
  buildInputs = [ rdma-core libfabric libnl perl ];

  enableParallelBuilding = true;

  doCheck = true;

  postPatch = ''
    patchShebangs ./
  '';

  preConfigure = ''
    ./autogen.sh
  '';

  checkPhase = ''
    fi_info
#export SHMEM_OFI_PROVIDER=sockets
#export SHMEM_OFI_FABRIC="127.0.0.1/8"
    export SHMEM_OFI_DOMAIN=lo
    make check TEST_RUNNER="mpiexec -n 2"
  '';

  meta = with stdenv.lib; {
    description = "Sandia open SHMEM implementation";
    homepage = https://github.com/Sandia-OpenSHMEM/SOS/releases;
    license = with licenses; gpl2;
    platforms = with platforms; linux;
  };
}

