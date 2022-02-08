{ stdenv
, lib
, fetchurl
}:

let
  pname = "zigbee2mqtt-networkmap";
  owner = "azuwis";
  version = "0.7.0";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/${owner}/${pname}/releases/download/v${version}/${pname}.js";
    hash = "sha256-OB2MOzFtSwzmW1b1wxBrWvW2GXdzf80vD/p+t5TN2jE=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -v $src $out/${pname}.js
  '';

  meta = with lib; {
    description = "Home Assistant custom card to show Zigbee2mqtt network map";
    homepage = "https://github.com/${owner}/${pname}";
    maintainers = with maintainers; [ plabadens ];
    license = licenses.mit;
  };
}
