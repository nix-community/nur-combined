{
  stdenv,
  fetchurl,
  python3,
}: let
  version = "2.12.1";
in
  stdenv.mkDerivation {
    inherit version;
    pname = "spot";

    buildInputs = [
      python3
    ];

    src = fetchurl {
      url = "https://www.lrde.epita.fr/dload/spot/spot-${version}.tar.gz";
      sha256 = "sha256-VHfAjU4dBi8WTC5IaoNVaSXQfXDyGA3nBq96qUnG/1w=";
    };
  }
