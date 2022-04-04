{ stdenv, lib, buildPythonPackage, quantlib, boost, swig, autoreconfHook, fetchurl }:

buildPythonPackage rec {
  pname = "quantlib";
  version = "1.21";
  
  # Not setting this to false, causes setuptools to be added to the
  # build inputs, which causes setuptools to build an egg.
  catchConflicts = false;

  src = fetchurl {
    url = "https://github.com/lballabio/QuantLib-SWIG/releases/download/QuantLib-SWIG-v${version}/QuantLib-SWIG-${version}.tar.gz";
    sha256 = "1ar8vklbbssmrwvwswi4nzndayszdv8ph8c72bw288vddhd3jxpr";
  };
  
  patches = [
    ./destdir-python.diff
  ];
  
  installFlags = [ "DESTDIR=$(out)" ];
    
  format = "other";
  buildInputs = [
    boost
  ];
  nativeBuildInputs = [
    quantlib # Quantlib doesn't get linked correctly, if it's not a native build input.
    swig
    autoreconfHook
  ];
  enableParallelBuilding = true;
  
  meta = with lib; {
    description = "Python wrappings for QuantLib";
    homepage = "https://www.quantlib.org/";
    license = licenses.bsd3;
  };
}
