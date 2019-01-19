{ stdenv, fetchsvn
, gfortran
, openmpi
, mpi ? openmpi
, netcdf
, netcdffortran
, hdf5
, perl
, perlPackages
, gnumake
, substituteAll
, xios
}:

let
  arch-X86_nix_fcm = substituteAll {
    src = ./arch-X86_nix.fcm;
    inherit netcdffortran xios;
    fc=if ((mpi.isIntel or false) && (stdenv.cc.isIntel or false)) then "mpiifort" else "mpif90";
    cc=if ((mpi.isIntel or false) && (stdenv.cc.isIntel or false)) then "mpiicc" else "mpicc";
    fflags=if (stdenv.cc.isIntel or false) then
      "-g -i4 -r8 -O3 -fp-model precise -fno-alias -traceback" else
      "-g -fdefault-real-8 -O3 -funroll-all-loops -fcray-pointer -ffree-line-length-none";
  };

in stdenv.mkDerivation {
  name = "nemo-3.6-10379";
  src = fetchsvn {
    url = "http://forge.ipsl.jussieu.fr/nemo/svn/NEMO/releases/release-3.6/NEMOGCM";
    rev = "10379";
    sha256 = "1pgaah508j9lya6mqasmxzs2j722ri4501346rvjcimkq560kc87";
  };
  buildInputs = [ gfortran mpi netcdf netcdffortran hdf5 perl
    perlPackages.URI
    gnumake
    xios
  ];
  patchPhase = ''
    patchShebangs .
  '';
  buildPhase = ''
    cp ${arch-X86_nix_fcm} ARCH/arch-X64_nix.fcm
    cat ARCH/arch-X64_nix.fcm
    (cd CONFIG; ./makenemo -r GYRE -n MY_GYRE -m X64_nix -j$(nproc))
  '';
  installPhase = ''
    mkdir -p $out/share/nemo/CONFIG/GYRE
    cp -av CONFIG/MY_GYRE/EXP00 $out/share/nemo/CONFIG/GYRE
    rm $out/share/nemo/CONFIG/GYRE/EXP00/opa
    cp -aLv CONFIG/MY_GYRE/BLD/bin/nemo.exe $out/share/nemo/CONFIG/GYRE/EXP00/opa
    cp -a CONFIG/SHARED $out/share/nemo/CONFIG

    # create symlink just to call nemo directly
    mkdir $out/bin
    ln -s $out/share/nemo/CONFIG/GYRE/EXP00/opa $out/bin/nemo
  '';
}
