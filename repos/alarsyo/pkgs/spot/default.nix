{
  stdenv,
  fetchurl,
  python3,
}: let
  version = "2.11.5";
in
  stdenv.mkDerivation {
    inherit version;
    pname = "spot";

    buildInputs = [
      python3
    ];

    src = fetchurl {
      url = "https://www.lrde.epita.fr/dload/spot/spot-${version}.tar.gz";
      sha256 = "sha256-Os/VzREtAFdqwjS66zThxq34wDFV1M2pc+Yxesi9F3Q=";
    };
  }
