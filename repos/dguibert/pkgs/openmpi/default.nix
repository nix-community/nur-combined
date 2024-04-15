{
  stdenv,
  fetchurl,
  fetchpatch,
  gfortran,
  perl,
  libnl,
  rdma-core,
  zlib,
  numactl,
  libevent,
  hwloc,
  targetPackages,
  symlinkJoin,
  libpsm2,
  libfabric,
  pmix,
  ucx,
  # Enable CUDA support
  cudaSupport ? false,
  cudaPackages,
  # Enable the Sun Grid Engine bindings
  enableSGE ? false,
  # Pass PATH/LD_LIBRARY_PATH to point to current mpirun by default
  enablePrefix ? false,
  # Enable libfabric support (necessary for Omnipath networks) on x86_64 linux
  fabricSupport ? stdenv.isLinux && stdenv.isx86_64,
  # Enable the Slurm bindings
  enableSlurm ? true,
  slurm ? null,
  lib,
  openmpi,
} @ args: let
  args_ = builtins.removeAttrs args ["lib" "openmpi" "enableSlurm" "slurm" "fetchpatch"];

  openmpi_2_0_2 = lib.upgradeOverride (openmpi.override args_) (oldAttrs: rec {
    version = "2.0.2";
    src = with lib.versions;
      fetchurl {
        url = "https://www.open-mpi.org/software/ompi/v${major version}.${minor version}/downloads/${oldAttrs.pname}-${version}.tar.gz";
        #url = "https://download.open-mpi.org/release/open-mpi/v2.0/openmpi-2.0.2.tar.gz";
        sha256 = "sha256-MpFMxkeA05gAZvO+OSCwKM04HJTRJipVQV/B0AK64KU=";
      };
    buildInputs =
      oldAttrs.buildInputs
      ++ lib.optionals enableSlurm [
        slurm
        /*
        pmix
        */
      ];
    configureFlags =
      oldAttrs.configureFlags
      ++ lib.optionals enableSlurm [
        "--with-slurm"
        "--with-pmix=internal"
        "--enable-mpi-fortran=all"
        #"--with-hwloc"
        #"--with-libevent"
      ];
  });

  openmpi_4_0_2 = lib.upgradeOverride (openmpi.override args_) (oldAttrs: rec {
    version = "4.0.2";
    src = with lib.versions;
      fetchurl {
        url = "https://www.open-mpi.org/software/ompi/v${major version}.${minor version}/downloads/${oldAttrs.pname}-${version}.tar.bz2";
        sha256 = "0ms0zvyxyy3pnx9qwib6zaljyp2b3ixny64xvq3czv3jpr8zf2wh";
      };
    buildInputs =
      oldAttrs.buildInputs
      ++ lib.optionals enableSlurm [slurm pmix];
    configureFlags =
      oldAttrs.configureFlags
      ++ [
        "--with-cma"
        "--enable-mpi-fortran=all"
      ]
      ++ lib.optional enableSlurm "--with-slurm --with-pmi=${pmix}"
      ++ lib.optional (ucx != null) "--enable-mca-no-build=btl-uct";
  });

  openmpi_4_1_1 = lib.upgradeOverride (openmpi.override args_) (oldAttrs: rec {
    #openmpi_4_1_1 = lib.upgradeOverride (openmpi) (oldAttrs: rec {
    version = "4.1.1";
    src = with lib.versions;
      fetchurl {
        url = "https://www.open-mpi.org/software/ompi/v${major version}.${minor version}/downloads/${oldAttrs.pname}-${version}.tar.bz2";
        sha256 = "1nkwq123vvmggcay48snm9qqmrh0bdzpln0l1jnp26niidvplkz2";
      };

    buildInputs =
      oldAttrs.buildInputs
      ++ lib.optionals enableSlurm [
        slurm
        /*
        pmix
        */
      ];
    configureFlags =
      oldAttrs.configureFlags
      ++ [
        "--with-cma"
        "--enable-mpi-fortran=all"
      ]
      ++ lib.optional enableSlurm "--with-slurm --with-pmi=${pmix}"
      ++ lib.optional (ucx != null) "--enable-mca-no-build=btl-uct";
  });

  self = {
    inherit openmpi_2_0_2;
    inherit openmpi_4_0_2;
    inherit openmpi_4_1_1;
  };
in
  self
