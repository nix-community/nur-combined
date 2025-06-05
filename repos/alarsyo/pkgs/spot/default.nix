{
  stdenv,
  fetchurl,
  python3,
}: let
  version = "2.13";
in
  stdenv.mkDerivation {
    inherit version;
    pname = "spot";

    buildInputs = [
      python3
    ];

    src = fetchurl {
      url = "https://www.lrde.epita.fr/dload/spot/spot-${version}.tar.gz";
      sha256 = "sha256-DQ/mc88byJM3J7yOC+e6NpAURSEeKUWsc/sJg1yB9Os=";
    };
  }
