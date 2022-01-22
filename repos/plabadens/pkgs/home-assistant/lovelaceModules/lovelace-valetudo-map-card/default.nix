{ stdenv
, lib
, fetchurl
}:

let
  pname = "lovelace-valetudo-map-card";
  version = "2022.01.2";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://raw.githubusercontent.com/TheLastProject/lovelace-valetudo-map-card/v${version}/valetudo-map-card.js";
    hash = "sha256-72bev9gvPN8ftIExJS/0EEXWz2kjYCVo42ce0eDdbnY=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -v $src $out/valetudo-map-card.js
  '';

  meta = with lib; {
    description = "Draws the map available from a Xiaomi Vacuum cleaner flashed with Valetudo in a Home Assistant Lovelace card";
    homepage = "https://github.com/TheLastProject/lovelace-valetudo-map-card";
    maintainers = with maintainers; [ plabadens ];
    license = licenses.mit;
  };
}
