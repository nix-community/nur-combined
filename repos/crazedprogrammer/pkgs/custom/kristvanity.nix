{ stdenv, fetchFromGitHub, cmake, openssl_1_1, tclap, pkgconfig }:

stdenv.mkDerivation rec {
  name = "kristvanity-${version}";
  version = "2018-07-11";

  src = fetchFromGitHub {
    owner = "Lignum";
    repo = "KristVanity";
    rev = "b381cb803db0cf599991087a138420a574d526c0";
    sha256 = "0s1i753c6794y780lnflclyj8j885j20yvfnikf8drygr6bfqywp";
  };

  buildInputs = [ cmake openssl_1_1 tclap pkgconfig ];

  meta = with stdenv; {
    homepage = https://github.com/Lignum/KristVanity;
  };
}
