{ lib, stdenv, pkgs, fetchFromGitLab, fetchpatch, cmake, gfortran, perl
, openblas, hdf5-full, python3, texlive
, armadillo, makeWrapper, fetchFromGitHub, chemps2
} :

let
  version = "19.11";
  gitLabRev = "v${version}";

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
    rev = gitLabRev;
    sha256 = "1wwqhkyyi7pw5x1ghnp83ir17zl5jsj7phhqxapybyi3bmg0i00q";
  };

  patches = [
  (fetchpatch {
    name = "openblas-multiple-output"; # upstream patch
    url = "https://raw.githubusercontent.com/NixOS/nixpkgs/8b02ff6b8eeb4896276c8777003736598a78d30d/pkgs/applications/science/chemistry/openmolcas/openblasPath.patch";
    sha256 = "0kk67924fp9243jh33h9c1d3hagn3s936w5b1s9hyih6nqygb3mc";
  })
  (fetchpatch {
    name = "Fix-MPI-INT-size"; # upstream patch
    url = "https://gitlab.com/Molcas/OpenMolcas/commit/860e3350523f05ab18e49a428febac8a4297b6e4.patch";
    sha256 = "0h96h5ikbi5l6ky41nkxmxfhjiykkiifq7vc2s3fdy1r1siv09sb";
  })
  (fetchpatch {
    name = "CIsandbox-IAND-fix"; # upstream patch
    url = "https://gitlab.com/Molcas/OpenMolcas/commit/d871590c8ce4689cd94cdbbc618954c65589393d.patch";
    sha256 = "0dgz1w2rkglnis76spai3m51qa72j4bz6ppnk5zmzrr6ql7gwpgg";
  })];

  prePatch = ''
    rm -r External/libwfa
    cp -r ${srcLibwfa} External/libwfa
    chmod -R u+w External/
  '';


  nativeBuildInputs = [ perl cmake texlive.combined.scheme-minimal makeWrapper ];
  buildInputs = [ gfortran openblas hdf5-full python armadillo chemps2];

  # tests are not running right now.
  doCheck = false;

  doInstallCheck = true;

  enableParallelBuilding = true;

  NIX_CFLAGS_COMPILE = "-DH5_USE_110_API";

  cmakeFlags = [
    "-DOPENMP=ON"
    "-DLINALG=${if (builtins.parseDrvName openblas.name).name == "mkl" then "MKL" else "OpenBLAS"}"
    "-DTOOLS=ON"
    "-DHDF5=ON"
    "-DFDE=ON"
    "-DWFA=ON"
    "-DCTEST=ON"
    "-DCHEMPS2=ON" "-DCHEMPS2_DIR=${chemps2}/bin"
  ] ++ (if (builtins.parseDrvName openblas.name).name == "mkl" then [ "-DMKLROOT=${openblas}" ] else  [ "-DOPENBLASROOT=${openblas.dev}" ]);

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

