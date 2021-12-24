{ stdenv
, lib
, fetchurl
}:

let
  pname = "weather-card-chart";
  version = "1.1.0";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/Yevgenium/weather-chart-card/releases/download/${version}/weather-chart-card.js";
    hash = "sha256:16j50dj22qr89rdg3z8b3l4y4lsj1rp1l20dm4faw18vvdmni3jz";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -v $src $out/weather-card-chart.js
  '';

  meta = with lib; {
    homepage = "https://github.com/Yevgenium/lovelace-weather-card-chart";
    description = "Custom weather card with charts";
    license = licenses.mit;
  };
}
