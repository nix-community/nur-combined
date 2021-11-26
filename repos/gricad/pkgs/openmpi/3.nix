{ stdenv, lib, fetchurl, gfortran, perl, libnl, rdma-core, zlib, psm2, libfabric 

# Enable the Sun Grid Engine bindings
, enableSGE ? false

# Pass PATH/LD_LIBRARY_PATH to point to current mpirun by default
, enablePrefix ? false
}:

let
  majorVersion = "3.1";
  minorVersion = "6";

in stdenv.mkDerivation rec {
  name = "openmpi-${majorVersion}.${minorVersion}";

  src = fetchurl {
    url = "http://www.open-mpi.org/software/ompi/v${majorVersion}/downloads/${name}.tar.bz2";
    sha256 = "0yfjl1kdy2xq0897vpcgy31630qphdin3mbl9mb1d9f25sc1s4sh";
  };

  postPatch = ''
    patchShebangs ./
  '';

  buildInputs = with lib; [ gfortran zlib ]
    ++ optional stdenv.isLinux libnl
    ++ optional stdenv.isLinux [ psm2 libfabric ]
    ++ optional (stdenv.isLinux || stdenv.isFreeBSD) rdma-core;

  nativeBuildInputs = [ perl ];

  configureFlags =  [ "--disable-mca-dso" ]
    ++ lib.optional stdenv.isLinux  "--with-libnl=${libnl.dev}"
    ++ lib.optional stdenv.isLinux  [ "--with-psm2=${psm2} --with-libfabric=${libfabric}" ]
    ++ lib.optional enableSGE "--with-sge"
    ++ lib.optional enablePrefix "--enable-mpirun-prefix-by-default"
    ;

  enableParallelBuilding = true;

  postInstall = ''
    rm -f $out/lib/*.la
   '';

  doCheck = true;

  meta = with lib; {
    homepage = http://www.open-mpi.org/;
    description = "Open source MPI-3 implementation";
    longDescription = "The Open MPI Project is an open source MPI-3 implementation that is developed and maintained by a consortium of academic, research, and industry partners. Open MPI is therefore able to combine the expertise, technologies, and resources from all across the High Performance Computing community in order to build the best MPI library available. Open MPI offers advantages for system and software vendors, application developers and computer science researchers.";
    maintainers = with maintainers; [ markuskowa ];
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
