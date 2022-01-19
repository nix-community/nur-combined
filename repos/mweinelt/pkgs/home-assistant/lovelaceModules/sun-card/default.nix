{ stdenv
, lib
, fetchurl
}:

let
  pname = "apexcharts-card";
  version = "0.1.4";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/AitorDB/home-assistant-sun-card/releases/download/v${version}/home-assistant-sun-card.js";
    hash = "sha256-1B566pKJLeB0AfiuZ7j+hyYgHqj43w4yCOT/PzH0UjA=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -v $src $out/sun-card.js
  '';

  meta = with lib; {
    description = "Home Assistant sun card based on Google weather design";
    homepage = "https://github.com/AitorDB/home-assistant-sun-card";
    maintainers = with maintainers; [ hexa ];
    license = licenses.mit;
  };
}

