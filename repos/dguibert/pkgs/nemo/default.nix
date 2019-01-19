{ stdenv, fetchsvn
, gfortran
, openmpi
, mpi ? openmpi
, netcdf
, netcdffortran
, hdf5
, perl
, perlPackages
, substituteAll
}:

let
  arch-X86_nix_fcm = substituteAll {
    src = ./arch-X86_nix.fcm;
    inherit netcdffortran;
    fc=if ((mpi.isIntel or false) && (stdenv.cc.isIntel or false)) then "mpiifort" else "mpif90";
    cc=if ((mpi.isIntel or false) && (stdenv.cc.isIntel or false)) then "mpiicc" else "mpicc";
    fflags=if (stdenv.cc.isIntel or false) then
      "-g -i4 -r8 -O3 -fp-model precise -fno-alias -traceback" else
      "-g -fdefault-real-8 -O3 -funroll-all-loops -fcray-pointer -ffree-line-length-none";
  };

in stdenv.mkDerivation {
  name = "nemo-3.6-10492";
  src = fetchsvn {
    url = "http://forge.ipsl.jussieu.fr/nemo/svn/NEMO/trunk";
    rev = "10492";
    sha256 = "0k5sric9bkri7l28vjyd225dwp4cbjja6p2lngzyprdlz012a794";
  };
  buildInputs = [ gfortran mpi netcdf netcdffortran hdf5 perl
    perlPackages.URI
  ];
  patchPhase = ''
    patchShebangs .
  '';
  buildPhase = ''
    cp ${arch-X86_nix_fcm} arch/arch-X64_nix.fcm
    cat arch/arch-X64_nix.fcm
    ./makenemo -a BENCH -m X64_nix -j$(nproc)
  '';
  installPhase = ''
    mkdir -p $out/share/nemo/tests/BENCH/
    cp -av cfgs $out/share/nemo
    cp -av tests/BENCH/EXP00 $out/share/nemo/tests/BENCH
    rm $out/share/nemo/tests/BENCH/EXP00/nemo
    cp -aLv tests/BENCH/EXP00/nemo $out/share/nemo/tests/BENCH/EXP00/

    # create symlink just to call nemo directly
    mkdir $out/bin
    ln -s $out/share/nemo/tests/BENCH/EXP00/nemo $out/bin/nemo
  '';
}
