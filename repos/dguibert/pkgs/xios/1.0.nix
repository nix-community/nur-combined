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
, blitz, boost166
}:
let
  blitz_ = blitz.override { boost = boost166; };
  netcdffortran_ = netcdffortran.override { netcdf = netcdf-mpi; hdf5 = hdf5-mpi; };

  arch-X86_nix_fcm = substituteAll {
    src = ./arch-X86_nix.fcm;
    inherit netcdffortran;
    boost = boost166;
    fc=if ((mpi.isIntel or false) && (stdenv.cc.isIntel or false)) then "mpiifort" else "mpif90";
    cc=if ((mpi.isIntel or false) && (stdenv.cc.isIntel or false)) then "mpiicc" else "mpicc";
    fflags=if (stdenv.cc.isIntel or false) then
      "-g -O3 -fp-model precise -fno-alias -traceback" else
      "-g -O3 -funroll-all-loops -fcray-pointer -ffree-line-length-none";
  };

  arch-X86_nix_path = substituteAll {
    src = ./arch-X86_nix.path;
    boost = boost166.dev;
    inherit blitz;
  };

in stdenv.mkDerivation {
  name = "xios-1.0.703";
  src = fetchsvn {
    url = "http://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/branchs/xios-1.0";
    rev = "703";
    sha256 = "0w598pi2y6ag2836b10qvz12kdxqxd9j41gqwkzlj3ji3yf8pcp4";
  };
  buildInputs = [ gfortran mpi perl netcdf-mpi netcdffortran_
    perlPackages.URI
    blitz_ boost166.all
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
    patch -i ${./xios-make.patch}
  '';
  buildPhase = ''
    cp ${arch-X86_nix_fcm} arch/arch-X64_nix.fcm
    sed -i -e "s@-std=c++11@-std=c++98@" arch/arch-X64_nix.fcm

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
