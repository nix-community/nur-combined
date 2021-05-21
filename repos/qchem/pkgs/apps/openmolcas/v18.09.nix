{ lib, stdenv, pkgs, fetchFromGitLab, fetchpatch, cmake, gfortran, perl
, blas-i8, hdf5-full, python3, texlive, symlinkJoin
, armadillo, makeWrapper, fetchFromGitHub, chemps2
} :

assert
  lib.asserts.assertMsg
  (blas-i8.isILP64 || blas-i8.passthru.implementation == "mkl")
  "A 64 int integer BLAS implementation is required.";

assert
  lib.asserts.assertMsg
  (builtins.elem blas-i8.passthru.implementation [ "openblas" "mkl" ])
  "OpenMolcas requires OpenBLAS or MKL.";

let
  version = "18.09-20180902";

  python = python3.withPackages (ps : with ps; [ six pyparsing ]);

  srcLibwfa = fetchFromGitHub {
    owner = "libwfa";
    repo = "libwfa";
    rev = "efd3d5bafd403f945e3ea5bee17d43e150ef78b2";
    sha256 = "0qzs8s0pjrda7icws3f1a55rklfw7b94468ym5zsgp86ikjf2rlz";
  };

in stdenv.mkDerivation {
  pname = "openmolcas";
  inherit version;

  src = fetchFromGitLab {
    owner = "Molcas";
    repo = "OpenMolcas";
    rev = "4df62e6695a3942a7acd3bf86af1001a164154ca";
    sha256 = "1y4dq6ddrrqyagppzn0gpjf81nhgkkla9rxp4r5k0qkyzg483d9r";
  };

  patches = [
    ./MKL-18.09.patch
  ];

  prePatch = ''
    rm -r External/libwfa
    cp -r ${srcLibwfa} External/libwfa
    chmod -R u+w External/
  '';


  nativeBuildInputs = [ perl cmake texlive.combined.scheme-minimal makeWrapper ];
  buildInputs = [
    gfortran
    (blas-i8.passthru.provider)
    hdf5-full
    python
    armadillo
    chemps2
  ];

  # tests are not running right now.
  doCheck = false;

  doInstallCheck = true;

  enableParallelBuilding = true;

  NIX_CFLAGS_COMPILE = "-DH5_USE_110_API";

  cmakeFlags = [
    "-DOPENMP=ON"
    "-DTOOLS=ON"
    "-DHDF5=ON"
    "-DFDE=ON"
    "-DWFA=ON"
    "-DCTEST=ON"
    "-DCHEMPS2=ON" "-DCHEMPS2_DIR=${chemps2}/bin"
  ] ++ lib.lists.optionals (blas-i8.passthru.implementation == "openblas") [
         "-DOPENBLASROOT=${symlinkJoin {
             name = "openblas";
             paths = [ blas-i8.passthru.provider.all ];
           }}"
         "-DLINALG=OpenBLAS" ]
    ++ lib.lists.optionals (blas-i8.passthru.implementation == "mkl") [
         "-DMKLROOT=${blas-i8.passthru.provider}"
         "-DLINALG=MKL"
         "-DMKL_LIBRARY_PATH=${blas-i8.passthru.provider}/lib"
         "-DLIBMKL_CORE=${blas-i8.passthru.provider}/lib/libmkl_core.so"
       ]
  ;

  postConfigure = ''
    # The Makefile will install pymolcas during the build grrr.
    mkdir -p $out/bin
    export PATH=$PATH:$out/bin
  '';

  postFixup = ''
    # Wrong store path in shebang (no Python pkgs), force re-patching
    sed -i "1s:/.*:/usr/bin/env python:" $out/bin/pymolcas
    patchShebangs $out/bin

    wrapProgram $out/bin/pymolcas \
      --set MOLCAS $out \
      --prefix PATH : "${chemps2}/bin"
  '';

  installCheckPhase = ''
     #
     # Minimal check if installation runs properly
     #

     export OMPI_MCA_rmaps_base_oversubscribe=1

     export MOLCAS_WORKDIR=./
     inp=water

     cat << EOF > $inp.xyz
     3
     Angstrom
     O       0.000000  0.000000  0.000000
     H       0.758602  0.000000  0.504284
     H       0.758602  0.000000 -0.504284
     EOF

     cat << EOF > $inp.inp
     &GATEWAY
     coord=water.xyz
     basis=sto-3g
     &SEWARD
     &SCF
     EOF

     $out/bin/pymolcas $inp.inp > $inp.out

     echo "Check for sucessful run:"
     grep "Happy landing" $inp.status
     echo "Check for correct energy:"
     grep "Total SCF energy" $inp.out | grep 74.880174
  '';

  checkPhase = ''
    make test
  '';

  meta = with lib; {
    description = "Quantum chemistry software package";
    homepage = https://gitlab.com/Molcas/OpenMolcas;
    maintainers = [ maintainers.markuskowa ];
    license = licenses.lgpl21;
    platforms = platforms.linux;
  };
}
