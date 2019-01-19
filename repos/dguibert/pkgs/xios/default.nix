{ stdenv, fetchsvn
, gfortran
, openmpi
, mpi ? openmpi
, substituteAll
, perl
, perlPackages
, netcdf-mpi
, netcdffortran
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
  name = "xios-2.0";
  src = fetchsvn {
    url = "http://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/trunk/";
    rev = "1637";
    sha256 = "196vv9mh22vs67pasr56478k25yw79z7sfzwc1x9cckydj9xim0m";
  };
  buildInputs = [ gfortran mpi perl netcdf-mpi netcdffortran
    perlPackages.URI
  ];
  patchPhase = ''
    # Installation des sources
    nb_files_gz=`ls tools/archive | grep tar.gz | wc -l`
    if [ ''${nb_files_gz} -ne 0 ]; then
      echo -e "- uncompress archives ..."
      for tarname in `ls tools/archive/*.tar.gz` ; do
        tar -vxf $tarname
        rm $tarname
      done
    fi
    patchShebangs .
  '';
  buildPhase = ''
    cp ${arch-X86_nix_fcm} arch/arch-X64_nix.fcm
    cp ${./arch-X86_nix.path} arch/arch-X64_nix.path
    touch arch/arch-X64_nix.env
    cat arch/arch-X64_nix.fcm
    bash -x ./make_xios --arch X64_nix --job $(nproc)
  '';
  installPhase = ''
    mkdir $out
    cp -a bin $out/bin
    cp -a lib $out/lib
    cp -a inc $out/include
  '';
}
