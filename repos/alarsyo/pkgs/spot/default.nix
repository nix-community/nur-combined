{
  stdenv,
  fetchurl,
  python3,
}: let
  version = "2.10.5";
in
  stdenv.mkDerivation {
    inherit version;
    pname = "spot";

    buildInputs = [
      python3
    ];

    src = fetchurl {
      url = "https://www.lrde.epita.fr/dload/spot/spot-${version}.tar.gz";
      sha256 = "sha256-40uaMF1VjTMCJWqZZe5fRAGyINyyvlJExksxJqeESio=";
    };
  }
