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
  drvFlavor,
  lib,
  config,
  name ? "nemo-${config}-${version}",
  version ? "x.x",
  src,
  postPatch ? "",
  makenemoFlags ? "",
  ...
}: let
  nemo_arch-X64_nix-fcm = substituteAll {
    src = ./arch-X64_nix.fcm;
    inherit netcdffortran xios;
    fc =
      if ((mpi.isIntel or false) && (stdenv.cc.isIntel or false))
      then "mpiifort"
      else "mpif90";
    cc =
      if ((mpi.isIntel or false) && (stdenv.cc.isIntel or false))
      then "mpiicc"
      else "mpicc";
    fflags =
      if (stdenv.cc.isIntel or false)
      then "-g -i4 -r8 -O3 -fp-model precise -fno-alias -traceback"
      else "-g -fdefault-real-8 -O3 -funroll-all-loops -fcray-pointer -ffree-line-length-none";
  };
in
  stdenv.mkDerivation {
    inherit name src;

    buildInputs = [
      gfortran
      mpi
      netcdf
      netcdffortran
      hdf5
      perl
      perlPackages.URI
      xios
    ];
    postPatch =
      ''
        patchShebangs .
      ''
      + postPatch;
    buildPhase = ''
      cp ${nemo_arch-X64_nix-fcm} arch/arch-X64_nix.fcm
      cat arch/arch-X64_nix.fcm
      if test -e tests/${config}; then
        ./makenemo -a ${config} -m X64_nix -j$(nproc) ${makenemoFlags}
      elif test -e cfgs/${config}; then
        ./makenemo -r ${config} -m X64_nix -j$(nproc) ${makenemoFlags}
      else
        echo "ERROR: neither 'tests/${config}' nor 'cfgs/${config}' can be found"
        exit 10
      fi
    '';
    installPhase = ''
      if test -e tests/${config}; then
        mkdir -p $out/share/nemo/tests/${config}/
        cp -av tests/${config}/EXP00 $out/share/nemo/tests/${config}
        rm $out/share/nemo/tests/${config}/EXP00/nemo
        cp -aLv tests/${config}/EXP00/nemo $out/share/nemo/tests/${config}/EXP00/

        # create symlink just to call nemo directly
        mkdir $out/bin
        ln -s $out/share/nemo/tests/${config}/EXP00/nemo $out/bin/nemo

      elif test -e cfgs/${config}; then

        mkdir -p $out/share/nemo/cfgs/${config}/
        cp -av cfgs/${config}/EXP00 $out/share/nemo/cfgs/${config}
        rm $out/share/nemo/cfgs/${config}/EXP00/nemo
        cp -aLv cfgs/${config}/EXP00/nemo $out/share/nemo/cfgs/${config}/EXP00/

        # create symlink just to call nemo directly
        mkdir $out/bin
        ln -s $out/share/nemo/cfgs/${config}/EXP00/nemo $out/bin/nemo

      fi
    '';

    # gcc 10 NIX_CFLAGS_COMPILE="-fallow-argument-mismatch";
    NIX_CFLAGS_COMPILE =
      if
        ((drvFlavor stdenv.cc.cc)
          == "gcc"
          && lib.versionAtLeast stdenv.cc.cc.version "10.0")
      then "-fallow-argument-mismatch"
      else "";
  }
