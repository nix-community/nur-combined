{ lib, stdenv, pkgs, fetchFromGitLab, fetchpatch, cmake, gfortran, perl
, blas-i8, hdf5-full, python3, texlive
, armadillo, makeWrapper, fetchFromGitHub, chemps2
} :

assert
  lib.asserts.assertMsg
  (blas-i8.isILP64 || blas-i8.passthru.implementation == "mkl")
  "A 64 bit integer BLAS implementation is required.";

assert
  lib.asserts.assertMsg
  (builtins.elem blas-i8.passthru.implementation [ "openblas" "mkl" ])
  "OpenMolcas requires OpenBLAS or MKL.";

let
  version = "21.06";

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
    rev = "v${version}";
    sha256 = "07dm73n0s7ckif561yb3s9yqxsv39a73kb9qwny4yp39wdvv52hz";
  };

  patches = [ (fetchpatch {
    name = "openblas-multiple-output"; # upstream patch
    url = "https://raw.githubusercontent.com/NixOS/nixpkgs/2eee4e4eac851a2846515dcfa3274c4ab92ecbe5/pkgs/applications/science/chemistry/openmolcas/openblasPath.patch";
    sha256 = "0l6z5zhfbfpbp9x58228nhhwwp1fzmi8cmmasvzddp84h31f0b8h";
  })
    ./MKL-MPICH.patch
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
    "-DOPENBLASROOT=${blas-i8.passthru.provider.dev}" "-DLINALG=OpenBLAS"
  ] ++ lib.lists.optionals (blas-i8.passthru.implementation == "mkl") [
    "-DMKLROOT=${blas-i8.passthru.provider}" "-DLINALG=MKL"
  ];

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

  postInstall = ''
    mv $out/pymolcas $out/bin
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
