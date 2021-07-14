{ lib, stdenv
, fetchurl
, python3
}:
let
  version = "2.9.7";
in
stdenv.mkDerivation {
  inherit version;
  pname = "spot";

  buildInputs = [
    python3
  ];

  src = fetchurl {
    url = "https://www.lrde.epita.fr/dload/spot/spot-${version}.tar.gz";
    sha256 = "sha256-Hupn40Rs27u3Be5uJv2GkCDNt9gsVj/q2ctDlLm6oEw=";
  };
}
