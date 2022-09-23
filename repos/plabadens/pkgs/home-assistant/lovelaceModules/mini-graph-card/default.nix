{ stdenv
, lib
, fetchurl
}:

let
  pname = "mini-graph-card";
  version = "0.11.0";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/kalkih/mini-graph-card/releases/download/v${version}/mini-graph-card-bundle.js";
    hash = "sha256-ujWSekx/DRS6fQzDyL79ZKGne5VHJwHBT6c88WECc1I=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -v $src $out/mini-graph-card.js
  '';

  meta = with lib; {
    description = "Minimalistic graph card for Home Assistant Lovelace UI";
    homepage = "https://github.com/kalkih/mini-graph-card";
    maintainers = with maintainers; [ plabadens ];
    license = licenses.mit;
  };
}
