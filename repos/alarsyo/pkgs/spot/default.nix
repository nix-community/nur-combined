{
  stdenv,
  fetchurl,
  python3,
}: let
  version = "2.10.6";
in
  stdenv.mkDerivation {
    inherit version;
    pname = "spot";

    buildInputs = [
      python3
    ];

    src = fetchurl {
      url = "https://www.lrde.epita.fr/dload/spot/spot-${version}.tar.gz";
      sha256 = "sha256-xYjRy1PM6j5ZL5lAKxTC9DZ7NJ7O+OF7bTkd8Ua8i6Q=";
    };
  }
