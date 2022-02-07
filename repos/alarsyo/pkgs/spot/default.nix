{ stdenv
, fetchurl
, python3
}:
let
  version = "2.10.4";
in
stdenv.mkDerivation {
  inherit version;
  pname = "spot";

  buildInputs = [
    python3
  ];

  src = fetchurl {
    url = "https://www.lrde.epita.fr/dload/spot/spot-${version}.tar.gz";
    sha256 = "sha256-6GKc22zOgwd4JpYM0B7OUhPar5ooPW9iqvaa+gYjR4o=";
  };
}
