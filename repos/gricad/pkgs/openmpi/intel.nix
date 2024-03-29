{ lib, stdenv, fetchurl, gfortran, perl, libnl
, rdma-core, zlib, numactl, libevent, hwloc, targetPackages, symlinkJoin
, libpsm2, libfabric, pmix, ucx, intel-oneapi, gcc, procps, glibc, flex

# Enable CUDA support
, cudaSupport ? false, cudatoolkit ? null

# Enable the Sun Grid Engine bindings
, enableSGE ? false

# Pass PATH/LD_LIBRARY_PATH to point to current mpirun by default
, enablePrefix ? false

# Enable libfabric support (necessary for Omnipath networks) on x86_64 linux
, fabricSupport ? stdenv.isLinux && stdenv.isx86_64

# Enable intel compilers
, withOneAPI ? false
}:

assert !cudaSupport || cudatoolkit != null;

let
  version = "4.1.1";

  cudatoolkit_joined = symlinkJoin {
    name = "${cudatoolkit.name}-unsplit";
    paths = [ cudatoolkit.out cudatoolkit.lib ];
  };
in stdenv.mkDerivation rec {
  pname = "openmpi";
  inherit version;

  src = with lib.versions; fetchurl {
    url = "https://www.open-mpi.org/software/ompi/v${major version}.${minor version}/downloads/${pname}-${version}.tar.bz2";
    sha256 = "1nkwq123vvmggcay48snm9qqmrh0bdzpln0l1jnp26niidvplkz2";
  };

  postPatch = ''
    patchShebangs ./

    # Ensure build is reproducible
    ts=`date -d @$SOURCE_DATE_EPOCH`
    sed -i 's/OPAL_CONFIGURE_USER=.*/OPAL_CONFIGURE_USER="nixbld"/' configure
    sed -i 's/OPAL_CONFIGURE_HOST=.*/OPAL_CONFIGURE_HOST="localhost"/' configure
    sed -i "s/OPAL_CONFIGURE_DATE=.*/OPAL_CONFIGURE_DATE=\"$ts\"/" configure
    find -name "Makefile.in" -exec sed -i "s/\`date\`/$ts/" \{} \;
  '';

  buildInputs = with stdenv; [ gfortran zlib ]
    ++ lib.optionals isLinux [ libnl numactl pmix ucx ]
    ++ lib.optionals cudaSupport [ cudatoolkit ]
    ++ [ libevent hwloc ]
    ++ lib.optional (isLinux || isFreeBSD) rdma-core
    ++ lib.optional fabricSupport [ libpsm2 libfabric ]
    ++ lib.optionals withOneAPI [ intel-oneapi ];

  nativeBuildInputs = [ perl procps glibc flex ];


  preConfigure = ''
    ${if withOneAPI then "source ${intel-oneapi}/setvars.sh" else ""}
    COMPILER=${if withOneAPI then "oneapi" else "cc"}
    if [ "$COMPILER" = "oneapi" ]
    then 
      export F77=ifort
      export FC=ifort
      export CC=icc
      export CXX=icpc
      #export GCCROOT=${gcc}
      #export GXXROOT=${gcc}
      export CFLAGS="-isystem ${stdenv.cc.cc}/include/c++/${stdenv.cc.version} -isystem ${stdenv.cc.cc}/include/c++/${stdenv.cc.version}/x86_64-unknown-linux-gnu $NIX_CFLAGS_COMPILE"
      export CFLAGS=`echo "$CFLAGS"|sed "s/isystem /I/g"`
      export CPPFLAGS="$CFLAGS"
      export LD_FLAGS="$NIX_LFLAGS"
    fi
  '';

  configureFlags = with stdenv; lib.optional (!cudaSupport) "--disable-mca-dso"
    ++ lib.optionals isLinux  [
      "--with-libnl=${libnl.dev}"
      "--with-pmix=${pmix}"
      "--with-pmix-libdir=${pmix}/lib"
      "--enable-mpi-cxx"
    ] ++ lib.optional enableSGE "--with-sge"
    ++ lib.optional enablePrefix "--enable-mpirun-prefix-by-default"
    # TODO: add UCX support, which is recommended to use with cuda for the most robust OpenMPI build
    # https://github.com/openucx/ucx
    # https://www.open-mpi.org/faq/?category=buildcuda
    ++ lib.optionals cudaSupport [ "--with-cuda=${cudatoolkit_joined}" "--enable-dlopen" ]
    ++ lib.optionals fabricSupport [ "--with-psm2=${libpsm2}" "--with-libfabric=${libfabric}" ]
    ;

  enableParallelBuilding = true;

  postInstall = ''
    rm -f $out/lib/*.la
   '';

  postFixup = ''
    # default compilers should be indentical to the
    # compilers at build time

    CC=${if withOneAPI then "${intel-oneapi}/compiler/latest/linux/bin/intel64/icc" else "${targetPackages.stdenv.cc}/bin/${targetPackages.stdenv.cc.targetPrefix}cc"}
    CPP=${if withOneAPI then "${intel-oneapi}/compiler/latest/linux/bin/intel64/icpc" else "${targetPackages.stdenv.cc}/bin/${targetPackages.stdenv.cc.targetPrefix}c++"}
    FORT=${if withOneAPI then "${intel-oneapi}/compiler/latest/linux/bin/intel64/ifort" else "${gfortran}/bin/${gfortran.targetPrefix}gfortran"}
    sed -i "s:compiler=.*:compiler=$CC:" \
      $out/share/openmpi/mpicc-wrapper-data.txt

    sed -i "s:compiler=.*:compiler=$CC:" \
       $out/share/openmpi/ortecc-wrapper-data.txt

    sed -i "s:compiler=.*:compiler=$CPP:" \
       $out/share/openmpi/mpic++-wrapper-data.txt

    sed -i "s:compiler=.*:compiler=$FORT:"  \
       $out/share/openmpi/mpifort-wrapper-data.txt
  '';

  doCheck = true;

  passthru = {
    inherit cudaSupport cudatoolkit;
  };

  meta = with lib; {
    homepage = "https://www.open-mpi.org/";
    description = "Open source MPI-3 implementation";
    longDescription = "The Open MPI Project is an open source MPI-3 implementation that is developed and maintained by a consortium of academic, research, and industry partners. Open MPI is therefore able to combine the expertise, technologies, and resources from all across the High Performance Computing community in order to build the best MPI library available. Open MPI offers advantages for system and software vendors, application developers and computer science researchers.";
    maintainers = with maintainers; [ markuskowa ];
    #license = licenses.bsd3;
    license = lib.licenses.unfree; # prevent NUR ci from building it (OneAPI version)
    platforms = platforms.unix;
  };
}
