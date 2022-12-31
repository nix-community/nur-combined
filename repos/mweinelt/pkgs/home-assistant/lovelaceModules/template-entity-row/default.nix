{ stdenv
, lib
, fetchurl
}:

let
  pname = "template-entity-row";
  version = "1.3.0";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://raw.githubusercontent.com/thomasloven/lovelace-template-entity-row/${version}/template-entity-row.js";
    hash = "sha256-aKJusx++0SyxOjZ03+1wIu9PMz8z6bVZtS9tk6T0S00=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -v $src $out/template-entity-row.js
  '';

  meta = with lib; {
    description = "Display whatever you want in an entities card row";
    homepage = "https://github.com/thomasloven/lovelace-template-entity-row";
    maintainers = with maintainers; [ hexa ];
    license = licenses.mit;
  };
}

