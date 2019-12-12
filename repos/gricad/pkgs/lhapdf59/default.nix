{ stdenv, fetchurl, gfortran, autoconf, python}:

 stdenv.mkDerivation rec {

     version = "5.9.1";
     name = "lhapdf59";

     src = fetchurl {
       url = "http://www.hepforge.org/archive/lhapdf/lhapdf-5.9.1.tar.gz";
       sha256 = "174ihr8cz02h4acdw65f9cprfd2m3kplfs5b5b72fmpjsx3b1fc6";
     };

     preConfigure=''
	substituteInPlace ./pyext/lhapdf_wrap.cc --replace "PyErr_Format(PyExc_RuntimeError, mesg);" "PyErr_Format(PyExc_RuntimeError, \"%s\", mesg);"
     '';

     buildInputs = [ gfortran autoconf python ];


     meta = {
        description = "LHApdf 59";
        homepage = "https://lhapdf.hepforge.org/";
        license = stdenv.lib.licenses.bsd3;
        platforms = stdenv.lib.platforms.all;
        broken = true;
     };
 }
