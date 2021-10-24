{ lib, stdenv
, fetchurl
, python3
}:
let
  version = "2.9.8";
in
stdenv.mkDerivation {
  inherit version;
  pname = "spot";

  buildInputs = [
    python3
  ];

  src = fetchurl {
    url = "https://www.lrde.epita.fr/dload/spot/spot-${version}.tar.gz";
    sha256 = "sha256-t/QEu5CjNaWRQ4Tsw/w6ICH/IsV+6XpAwHuyq0DiDPk=";
  };
}
