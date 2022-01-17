{ stdenv
, fetchurl
, python3
}:
let
  version = "2.10.3";
in
stdenv.mkDerivation {
  inherit version;
  pname = "spot";

  buildInputs = [
    python3
  ];

  src = fetchurl {
    url = "https://www.lrde.epita.fr/dload/spot/spot-${version}.tar.gz";
    sha256 = "sha256-iX6VSGFzdI8rZe7L2ZojS39od/IYboaNp6zlZxgEAZ8=";
  };
}
