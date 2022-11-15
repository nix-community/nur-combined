{ stdenv
, lib
, fetchurl
}:

let
  pname = "button-card";
  version = "3.4.2";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/custom-cards/button-card/releases/download/v${version}/button-card.js";
    hash = "sha256-1S4WANFZkVuvtCQAfAPSO3+rRq7ItWLbisMJaAoMeUI=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -v $src $out/button-card.js
  '';

  meta = with lib; {
    description = "Lovelace button-card for home assistant";
    homepage = "https://github.com/custom-cards/button-card";
    maintainers = with maintainers; [ hexa ];
    license = licenses.mit;
  };
}

