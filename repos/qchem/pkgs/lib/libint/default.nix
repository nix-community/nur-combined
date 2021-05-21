{ lib, stdenv, fetchFromGitHub, fetchpatch, autoconf, automake, libtool
, python, perl, gmpxx, mpfr, boost, eigen, gfortran
, optAVX ? false
, cfg ? [
    "--enable-eri=1"
    "--enable-eri2=1"
    "--enable-eri3=1"
    "--with-max-am=5"
    "--with-eri-max-am=5,4"
    "--with-eri2-max-am=7,6"
    "--with-eri3-max-am=7,6"
   ]
} :

stdenv.mkDerivation rec {
  pname = "libint2";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "evaleev";
    repo = "libint";
    rev = "v${version}";
    sha256 = "0pbc2j928jyffhdp4x5bkw68mqmx610qqhnb223vdzr0n2yj5y19";
  };

  patches = [
    ./patches/fortran_bindings_debian.patch
  ];

  postPatch = ''
    find -name Makefile -exec sed -i 's:/bin/rm:rm:' \{} \;
  '';

  nativeBuildInputs = [ autoconf automake libtool mpfr ];
  buildInputs = [ python perl gmpxx boost gfortran ];

  enableParallelBuilding = true;

  doCheck = true;

  configureFlags = cfg
    ++ lib.optional optAVX "--enable-fma";

  preConfigure = ''
    ./autogen.sh
  '';

  postBuild = ''
    # build the fortran interface file
    cd export/fortran
    make libint_f.o ENABLE_FORTRAN=yes
    cd ../..
  '';

  postInstall = ''
    cp export/fortran/libint_f.mod $out/include/
  '';

  meta = with lib; {
    description = "Library for the evaluation of molecular integrals of many-body operators over Gaussian functions";
    homepage = https://github.com/evaleev/libint;
    license = with licenses; [ lgpl3Only gpl3Only ];
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}
