{ stdenv
, lib
, cfitsio
, fetchgit
, fetchurl
, gfortran
, hdf5-fortran
, llvmPackages
, makeWrapper
, sprng2
, voro
, xgboost
}:

stdenv.mkDerivation rec {

  pname = "mcfost";
  version = "v3.0.36";

  srcs = [
    (
      fetchgit {
        url = "https://github.com/cpinte/mcfost.git";
        rev = version;
        sha256 = "1c9bicy31cqvax5il7cdbg8q5v79fl9c426zb7f45bj15xhar5b6";
      }
    )
    (
      fetchurl {
        url = "http://ipag.osug.fr/public/pintec/mcfost_utils/mcfost_utils.tgz";
        sha256 = "sha256-2P2aSwqHiDz4a4lrxHTga8Yi7qI06wxFvYN8xjDokWI=";
      }
    )
  ];

  patches = [ ./makefile.patch ./sha.patch ];

  nativeBuildInputs = [
    gfortran
    makeWrapper
  ] ++ lib.optional stdenv.isDarwin llvmPackages.openmp;

  buildInputs = [
    cfitsio
    hdf5-fortran
    sprng2
    voro
    xgboost
  ];

  postUnpack = ''
    mkdir mcfost_utils
    mv Dust Isochrones Lambda Molecules Stellar_Polarization \
       Stellar_Spectra Version forProDiMo mcfost_utils
  '';

  sourceRoot = "mcfost";

  postPatch = ''
    substituteInPlace src/sha.f90 --replace @MCFOST_GIT_REV@ ${version}
  '';

  buildPhase = ''
    cd src
    make MCFOST_INSTALL=$out MCFOST_GIT=0 OPENMP=yes INCLUDE=-I${hdf5-fortran.dev}/include
  '';

  installPhase = ''
    install -d $out/bin
    install mcfost $out/bin
    mkdir -p $out/share
    cp -r ../../mcfost_utils $out/share
    wrapProgram $out/bin/mcfost --set MCFOST_AUTO_UPDATE 0 \
       --set MCFOST_UTILS $out/share/mcfost_utils
  '';

  meta = with lib; {
    description = "3D continuum and line radiative transfer code based on the Monte Carlo method";
    homepage = "https://github.com/cpinte/mcfost";
    license = licenses.gpl3;
  };

}
