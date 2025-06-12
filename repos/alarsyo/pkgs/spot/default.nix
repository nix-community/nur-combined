{
  stdenv,
  fetchurl,
  python3,
}: let
  version = "2.13.1";
in
  stdenv.mkDerivation {
    inherit version;
    pname = "spot";

    buildInputs = [
      python3
    ];

    src = fetchurl {
      url = "https://www.lrde.epita.fr/dload/spot/spot-${version}.tar.gz";
      sha256 = "sha256-udHeSrzQafkj4aMmP1jMr8xUiWqoGLRVkoyisaRGbck";
    };
  }
