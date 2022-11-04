{ lib
, stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "mushroom";
  version = "2.3.2";

  src = fetchurl {
    url = "https://github.com/piitaya/lovelace-mushroom/releases/download/v${version}/mushroom.js";
    hash = "sha256-VNsTPLy+00aTFBThCox8r6tfjE+XVXX6hfyboTsHEzo=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -v $src $out/mushroom.js
  '';

  meta = with lib; {
    changelog = "https://github.com/piitaya/lovelace-mushroom/releases/tag/v${version}";
    description = "Mushroom Cards - Build a beautiful dashboard easily";
    homepage = "https://github.com/piitaya/lovelace-mushroom";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}
