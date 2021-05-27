{ lib, stdenv, fetchFromGitHub, autoconf, automake, libtool
, rdma-core, libfabric, libnl, perl, mpi, openssh
} :

let
  version = "1.5.0";

in stdenv.mkDerivation {
  name = "sos-${version}";

  src = fetchFromGitHub {
    owner = "Sandia-OpenSHMEM";
    repo = "SOS";
    rev = "v${version}";
    sha256 = "0wj3ijxawpy5i33j7lnrlk4h6fhww0n3cwjfk28fpnxz30spcfwk";
  };

  configureFlags = [
    "--enable-pmi-simple"
    "--with-cma"
    "--with-ofi=${libfabric}"
  ];

  nativeBuildInputs = [ autoconf automake libtool openssh ];
  buildInputs = [ rdma-core libfabric libnl perl ];
  propagatedBuildInputs = [ mpi ];

  enableParallelBuilding = true;

  doCheck = true;

  postPatch = ''
    patchShebangs ./
  '';

  preConfigure = ''
    ./autogen.sh
  '';

  checkPhase = ''
    export OMPI_MCA_rmaps_base_oversubscribe=1
    export HYDRA_IFACE=lo
    export SHMEM_OFI_DOMAIN=lo
    make check TEST_RUNNER="mpiexec -n 2"
  '';

  passthru = { inherit mpi; };

  meta = with lib; {
    description = "Sandia open SHMEM implementation";
    homepage = https://github.com/Sandia-OpenSHMEM/SOS/releases;
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
