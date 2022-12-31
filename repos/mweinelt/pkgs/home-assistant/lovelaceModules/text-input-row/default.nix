{ stdenv
, lib
, fetchurl
}:

let
  pname = "text-input-row";
  version = "0.0.8";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/gadgetchnnel/lovelace-text-input-row/raw/v${version}/lovelace-text-input-row.js";
    hash = "sha256-tsLnetTSHBi3bGeDHBHrrGDzdDobBOQ73CZNbc8AlPc=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -v $src $out/text-input-row.js
  '';

  meta = with lib; {
    description = "A custom Lovelace text input row for use in entities cards";
    homepage = "https://github.com/gadgetchnnel/lovelace-text-input-row";
    maintainers = with maintainers; [ hexa ];
    license = licenses.unfree;
  };
}

