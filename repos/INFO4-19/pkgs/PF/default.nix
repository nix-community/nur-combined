{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  version = "4.07.1";
  name = "ocaml-${version}";
  builder = ./builder.sh;
  src = fetchurl {
    url = "http://caml.inria.fr/pub/distrib/ocaml-4.07/ocaml-${version}.tar.gz";
    sha256 = "1x4sln131mcspisr22qc304590rvg720rbl7g2i4xiymgvhkpm1a";
  };
}