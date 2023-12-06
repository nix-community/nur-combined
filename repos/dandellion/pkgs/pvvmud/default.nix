{ lib, stdenv, fetchurl, yacc, flex, libtiff }:

stdenv.mkDerivation {
  pname = "pvvmud";
  version = "0.1";

  nativeBuildInputs = [ yacc flex ];
  buildInputs = [ libtiff ];

  patches = [ ./0001-replace-iostream.patch ];

  src = fetchurl {
    url = "http://pvv.org/pvvmud/download/pvvmud_0-1.tar.gz";
    sha256 = "1a79l81j3iifm1ly6pc5sbc7mdbjim2yf6wnjrsp0kggqgrylc22";
  };

  meta.broken = true;
}
