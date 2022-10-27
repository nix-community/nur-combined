{
  stdenv,
  fetchurl,
  python3,
}: let
  version = "2.11.2";
in
  stdenv.mkDerivation {
    inherit version;
    pname = "spot";

    buildInputs = [
      python3
    ];

    src = fetchurl {
      url = "https://www.lrde.epita.fr/dload/spot/spot-${version}.tar.gz";
      sha256 = "sha256-PmNFjw2khj4c0NLP6FGhAV0yIgXX5AbGqdlWgLnqdU4=";
    };
  }
