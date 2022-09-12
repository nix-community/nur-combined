{ stdenv
, lib
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "rgb-light-card";
  version = "1.11.0";

  src = fetchurl {
    url = "https://github.com/bokub/rgb-light-card/releases/download/${version}/card.js";
    hash = "sha256-FgJ9sVTnEQfk7+SCzRiKYy+xV9wYNEdjkbL24FddfiM=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp $src $out/rgb-light-card.js
  '';

  meta = with lib; {
    homepage = "https://github.com/bokub/rgb-light-card";
    description = "A Lovelace custom card for RGB lights";
    license = licenses.mit;
  };
}
