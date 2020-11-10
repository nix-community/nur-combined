{ stdenv, fetchurl, autoreconfHook
, doxygen, texlive, python, perl, gmpxx, mpfr, boost
} :

let
  version = "1.1.5";

in stdenv.mkDerivation {
  pname = "libint";
  inherit version;

  src = fetchurl {
    url = "mirror://sourceforge/libint/libint-${version}.tar.gz";
    sha256 = "1621khq4zlhwxvycjqjriz2xr2rmm5dw3pgwccw7f6kv7iaxvmri";
  };

  hardeningDisable = [ "format" ];

  postPatch = ''
    find -exec sed -i 's:/bin/rm:rm:' \{} \;
  '';

  nativeBuildInputs = [ doxygen texlive.combined.scheme-small mpfr ];
  buildInputs = [ python perl gmpxx boost ];

  enableParallelBuilding = true;

  doCheck = true;

  configureFlags = [
    "--with-libint-max-am=6"
    "--with-libderiv-max-am1=5"
  ];

  meta = with stdenv.lib; {
    description = "Library for the evaluation of molecular integrals of many-body operators over Gaussian functions";
    homepage = https://github.com/evaleev/libint;
    license = licenses.lgpl3;
    platforms = platforms.linux;
  };
}

