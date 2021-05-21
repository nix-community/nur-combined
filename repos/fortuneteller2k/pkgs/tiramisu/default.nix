{ lib, stdenv, pkg-config, glib }:

stdenv.mkDerivation rec {
  pname = "tiramisu";
  version = "the-one-thats-not-in-nixpkgs";

  src = ./src;

  postPatch = ''
    sed -i 's/printf(element_delimiter)/printf("%s", element_delimiter)/' src/output.c
  '';

  buildInputs = [ glib ];

  nativeBuildInputs = [ pkg-config ];

  makeFlags = [ "PREFIX=$(out)" ];
}
