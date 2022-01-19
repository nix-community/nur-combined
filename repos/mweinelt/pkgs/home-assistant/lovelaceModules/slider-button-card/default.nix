{ stdenv
, lib
, fetchurl
}:

let
  pname = "slider-button-card";
  version = "1.10.3";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/mattieha/slider-button-card/releases/download/v${version}/slider-button-card.js";
    hash = "sha256-2SUyjbh5OTVMlnGuWowYoyEX2NGsksPwS1hcKTu7ToA=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -v $src $out/slider-button-card.js
  '';

  meta = with lib; {
    description = "Lovelace Slider button card";
    homepage = "https://github.com/mattieha/slider-button-card";
    maintainers = with maintainers; [ hexa ];
    license = licenses.mit;
  };
}

