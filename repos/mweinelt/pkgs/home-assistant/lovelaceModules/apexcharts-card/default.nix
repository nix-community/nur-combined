{ stdenv
, lib
, fetchurl
}:

let
  pname = "apexcharts-card";
  version = "1.10.1-dev.2";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/RomRider/apexcharts-card/releases/download/v${version}/apexcharts-card.js";
    hash = "sha256-JiVQJf8FGbB7jpM9WIiCJfL7ppFQSVZ52QgwWtgAG0Y=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -v $src $out/apexcharts-card.js
  '';

  meta = with lib; {
    description = "A Lovelace card to display advanced graphs and charts based on ApexChartsJS";
    homepage = "https://github.com/RomRider/apexcharts-card";
    maintainers = with maintainers; [ hexa ];
    license = licenses.mit;
  };
}

