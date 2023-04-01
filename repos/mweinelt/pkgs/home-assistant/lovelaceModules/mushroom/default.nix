{ lib
, stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "mushroom";
  version = "2.6.3";

  src = fetchurl {
    url = "https://github.com/piitaya/lovelace-mushroom/releases/download/v${version}/mushroom.js";
    hash = "sha256-fFONpLG0OA0uDO01ZlbKyK2vYoy+kmctWjL/0xR7LOI=";
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
