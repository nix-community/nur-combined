{ lib
, stdenv
, pkgs
, fetchurl
, python3
, cmake
, maintainers
, withOpenmpi? true
, withMpich? false
, withFortran? false
, pythonSupport ? true
, zfpSupport ? true
, shared ? !stdenv.hostPlatform.isStatic,
...
}:

# https://github.com/spack/spack/blob/develop/var/spack/repos/builtin/packages/conduit/package.py

let
   onOffBool = b: if b then "ON" else "OFF";
   withMPI = (withMpich == true || withOpenmpi == true);
in

# We can't have both mpis being used (is this the right way to do this?)
assert (withMpich && !withOpenmpi) || (!withMpich && withOpenmpi) || (!withMpich && !withOpenmpi);


stdenv.mkDerivation rec {
  pname = "conduit";
  version = "0.8.4";

  src = fetchurl {
    # spack defaults to providing the "with blt" url so we will too
    # url = "https://github.com/LLNL/conduit/archive/v${version}.tar.gz";
    url = "https://github.com/LLNL/conduit/releases/download/v${version}/conduit-v${version}-src-with-blt.tar.gz";
    sha256 = "55c37ddc668dbc45d43b60c440192f76e688a530d64f9fe1a9c7fdad8cd525fd";
  };

  # We can eventually add these variants/extra deps if needed
  # https://github.com/spack/spack/blob/develop/var/spack/repos/builtin/packages/conduit/package.py#L70-L103

  # Not sure what silo is (or if we need it)
  # depends_on("silo+shared", when="+silo+shared")
  # depends_on("silo~shared", when="+silo~shared")

  # Not sure if we need adios
  # depends_on("adios+mpi~hdf5+shared", when="+adios+mpi+shared")
  # depends_on("adios+mpi~hdf5~shared~blosc", when="+adios+mpi~shared")
  # depends_on("adios~mpi~hdf5+shared", when="+adios~mpi+shared")
  # depends_on("adios~mpi~hdf5~shared~blosc", when="+adios~mpi~shared")

  # hdf5 zfp plugin when both hdf5 and zfp are on
  # depends_on("h5z-zfp~fortran", when="+hdf5+zfp")

  # Not sure if we need parmetis
  # depends_on("parmetis", when="+parmetis")
  # depends_on("metis", when="+parmetis")

  # Assume not building docs for now
  # depends_on("py-sphinx", when="+python+doc", type="build")
  # depends_on("py-sphinx-rtd-theme", when="+python+doc", type="build")
  # depends_on("doxygen", when="+doc+doxygen")

  # Do we need hdf5-shared?
  # depends_on("hdf5", when="+hdf5")
  # depends_on("hdf5~shared", when="+hdf5~shared")

  nativeBuildInputs = [cmake pkgs.bash pkgs.extra-cmake-modules pkgs.tree pkgs.hdf5];
  buildInputs =
    lib.optional pythonSupport pkgs.python39 ++
    lib.optional pythonSupport pkgs.python39Packages.numpy ++
    lib.optional pythonSupport pkgs.python39Packages.mpi4py ++
    lib.optional zfpSupport pkgs.zfp ++

    # These shouldn't be both provided
    lib.optional withOpenmpi pkgs.openmpi ++
    lib.optional withMpich pkgs.mpich ++
    lib.optional withFortran pkgs.fortran;

  preConfigure = ''
   cd ./src
  '';

  cmakeFlags = [
    "-DENABLE_MPI=${onOffBool withMPI}"
    "-DENABLE_FIND_MPI=${onOffBool withMPI}"
    "-DBUILD_SHARED_LIBS=${onOffBool shared}"
    "-DENABLE_FORTRAN=${onOffBool withFortran}"
    "-DENABLE_PYTHON=${onOffBool pythonSupport}"
    "-DHDF5_DIR=${lib.getDev pkgs.hdf5}"
    "-DENABLE_UTILS=ON"
    "-DENABLE_EXAMPLES=ON"
    "-DBUILD_TESTS=OFF"
    "-DBUILD_DOCS=OFF"
  ];

  meta = with lib; {
    description = "Program instrumentation and performance measurement framework";
    longDescription = ''
      An open source project from Lawrence Livermore National
      Laboratory that provides an intuitive model for describing hierarchical
      scientific data in C++, C, Fortran, and Python. It is used for data
      coupling between packages in-core, serialization, and I/O tasks.
    '';
    homepage = "https://software.llnl.gov/conduit";
    license = licenses.bsd3;
    maintainers = [ maintainers.vsoch ];
    platforms = platforms.linux;
  };
}
