{ stdenv, fetchurl, perl }:

stdenv.mkDerivation rec {
  pname = "moarvm";
  version = "2019.07.1";

  src = fetchurl {
    url    = "https://github.com/MoarVM/MoarVM/releases/download/2019.07.1/MoarVM-2019.07.1.tar.gz";
    sha256 = "122rjns4sqs9yn7f34316aygrgj28n0pg3lvjkkfv2dmwrg98g15";
  };

  buildInputs = [ perl ];
  doCheck = false; # MoarVM does not come with its own test suite

  configureScript = "${perl}/bin/perl ./Configure.pl";

  meta = with stdenv.lib; {
    description = "MoarVM (short for Metamodel On A Runtime Virtual Machine) is a runtime built for the 6model object system";
    homepage    = "https://github.com/MoarVM/MoarVM";
    license     = licenses.artistic2;
    platforms   = platforms.unix;
  };
}
