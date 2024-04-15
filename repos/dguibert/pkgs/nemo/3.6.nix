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
  xios_10,
  fetchpatch,
  lib,
  ...
} @ args:
(import ./generic.nix ({
    name = "nemo_3.6-10379";
    config = "GYRE";
    src = fetchsvn {
      url = "http://forge.ipsl.jussieu.fr/nemo/svn/NEMO/releases/release-3.6/NEMOGCM";
      rev = "10379";
      sha256 = "1pgaah508j9lya6mqasmxzs2j722ri4501346rvjcimkq560kc87";
    };
    xios = xios_10;
  }
  // args))
// {
  installPhase = ''
    mkdir -p $out/share/nemo/CONFIG/GYRE
    cp -av CONFIG/GYRE/EXP00 $out/share/nemo/CONFIG/GYRE
    rm $out/share/nemo/CONFIG/GYRE/EXP00/opa
    cp -aLv CONFIG/GYRE/BLD/bin/nemo.exe $out/share/nemo/CONFIG/GYRE/EXP00/opa
    cp -a CONFIG/SHARED $out/share/nemo/CONFIG

    # create symlink just to call nemo directly
    mkdir $out/bin
    ln -s $out/share/nemo/CONFIG/GYRE/EXP00/opa $out/bin/nemo
  '';
}
