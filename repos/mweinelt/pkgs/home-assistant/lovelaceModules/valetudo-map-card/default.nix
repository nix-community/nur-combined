{ stdenv
, lib
, fetchurl
}:

let
  pname = "valetudo-map-card";
  version = "2022.01.2";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://raw.githubusercontent.com/TheLastProject/lovelace-valetudo-map-card/v${version}/valetudo-map-card.js";
    hash = "sha256:0xkfvphd27k7wdl2aq13d77xci8hyhpjacc1nhgxyg1gv2zxwrpg";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -v $src $out/valetudo-map-card.js
  '';

  meta = with lib; {
    description = "A card that draws the map from a Xiaomi vacuum cleaner, that is rooted and flashed with Valetudo";
    homepage = "https://github.com/TheLastProject/lovelace-valetudo-map-card";
    maintainers = with maintainers; [ hexa ];
    license = licenses.mit;
  };
}

