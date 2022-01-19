{ stdenv
, lib
, fetchurl
}:

let
  pname = "mini-graph-card";
  version = "0.11.0-dev.5";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/kalkih/mini-graph-card/releases/download/v${version}/mini-graph-card-bundle.js";
    hash = "sha256-+8kidgFiHwPGjQAEM2Mi/1aIOmx7iqP6owkAe8fxZyQ=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -v $src $out/mini-graph-card-bundle.js
  '';

  meta = with lib; {
    description = "Minimalistic graph card for Home Assistant Lovelace UI";
    homepage = "https://github.com/kalkih/mini-graph-card";
    maintainers = with maintainers; [ hexa ];
    license = licenses.mit;
  };
}

