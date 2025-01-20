{
  stdenv,
  fetchurl,
  python3,
}: let
  version = "2.12.2";
in
  stdenv.mkDerivation {
    inherit version;
    pname = "spot";

    buildInputs = [
      python3
    ];

    src = fetchurl {
      url = "https://www.lrde.epita.fr/dload/spot/spot-${version}.tar.gz";
      sha256 = "sha256-NhMOU23GqH+twsRLSrL2tBfVpP8879GZy+TqUbogdyQ";
    };
  }
