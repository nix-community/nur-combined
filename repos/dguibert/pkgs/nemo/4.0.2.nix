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
    name = "nemo-bench-4.0.2-12578";
    config = "BENCH";
    src = fetchsvn {
      url = "http://forge.ipsl.jussieu.fr/nemo/svn/NEMO/releases/r4.0/r4.0.2";
      rev = "12578";
      sha256 = "sha256-nDehVdEs0ndd5Ti/GAQuLbLza5V8N7Y6DxZMslMZ5wg=";
    };
  }
  // args)
