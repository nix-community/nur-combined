{ stdenv, fetchsvn
, gfortran
, openmpi
, mpi ? openmpi
, substituteAll
, perl
, perlPackages
, netcdf-mpi
, netcdffortran
, hdf5-mpi
, blitz, boost
, gcc
}:
let
  netcdffortran_ = netcdffortran.override { netcdf = netcdf-mpi; hdf5 = hdf5-mpi; };

  arch-X86_nix_fcm = substituteAll {
    src = ./arch-X86_nix.fcm;
    inherit netcdffortran boost;
    fc=if ((mpi.isIntel or false) && (stdenv.cc.isIntel or false)) then "mpiifort" else "mpif90";
    cc=if ((mpi.isIntel or false) && (stdenv.cc.isIntel or false)) then "mpiicc" else "mpicc";
    fflags=if (stdenv.cc.isIntel or false) then
      "-g -i4 -r8 -O3 -fp-model precise -fno-alias -traceback" else
      "-g -fdefault-real-8 -O3 -funroll-all-loops -fcray-pointer -ffree-line-length-none";
  };

  arch-X86_nix_path = substituteAll {
    src = ./arch-X86_nix.path;
    boost = boost.dev;
    inherit blitz;
  };


in stdenv.mkDerivation {
  name = "xios-2.0";
  src = fetchsvn {
    url = "http://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/trunk/";
    rev = "1637";
    sha256 = "196vv9mh22vs67pasr56478k25yw79z7sfzwc1x9cckydj9xim0m";
  };
  buildInputs = [ gfortran mpi perl netcdf-mpi netcdffortran_
    perlPackages.URI
    blitz boost.all
    gcc /* cpp */
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
    sed -i -e 's/src::date/#src::date/' bld.cfg
    sed -i -e 's/src::blitz/#src::blitz/' bld.cfg
  '';
  buildPhase = ''
    cp ${arch-X86_nix_fcm} arch/arch-X64_nix.fcm
    cp ${arch-X86_nix_path} arch/arch-X64_nix.path
    touch arch/arch-X64_nix.env
    cat arch/arch-X64_nix.fcm
    bash -x ./make_xios --arch X64_nix --job $(nproc) --use_extern_boost --use_extern_blitz
  '';
  installPhase = ''
    mkdir $out
    cp -a bin $out/bin
    cp -a lib $out/lib
    cp -a inc $out/include
  '';
}
