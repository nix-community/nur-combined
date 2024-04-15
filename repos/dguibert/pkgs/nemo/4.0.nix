{
  stdenv,
  fetchsvn,
  gfortran,
  openmpi,
  mpi ? openmpi,
  netcdf,
  netcdffortran,
  hdf5,
  perl,
  perlPackages,
  substituteAll,
  xios,
  lib,
  drvFlavor,
  ...
} @ args:
import ./generic.nix ({
    name = "nemo-bench-4.0-10741";
    config = "BENCH";
    src = fetchsvn {
      url = "http://forge.ipsl.jussieu.fr/nemo/svn/NEMO/releases/release-4.0";
      rev = "10741";
      sha256 = "1w8hv1alqvyl5lgjd9xw3kfbvj15sp0aaf9ky0s151kcvkdjm40j";
    };
  }
  // args)
