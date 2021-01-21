{ stdenv, fetchurl, autoreconfHook
, doxygen, texlive, python, perl, gmpxx, mpfr, boost
, maxAm ? 6
} :
assert
  stdenv.lib.asserts.assertMsg
  (maxAm <= 7 && maxAm >= 1)
  "The maximum angular momentum must be in the interval between 1 and 7";

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
    "--with-libint-max-am=${toString maxAm}"
    "--with-libderiv-max-am1=${toString (maxAm - 1)}"
  ];

  meta = with stdenv.lib; {
    description = "Library for the evaluation of molecular integrals of many-body operators over Gaussian functions";
    homepage = https://github.com/evaleev/libint;
    license = licenses.lgpl3;
    platforms = platforms.linux;
  };
}
