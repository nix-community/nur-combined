{ lib
, stdenvNoCC
, callPackage
, keycloak-lantian
, nodejs
, system
, ...
} @ args:

let
  nodeModules = "${keycloak-lantian.packages.${system}.package}/lib/node_modules/keycloak-lantian/node_modules";
in
stdenvNoCC.mkDerivation {
  name = "keycloak-lantian";
  src = "${keycloak-lantian}";
  buildInputs = [ nodejs ];
  buildPhase = ''
    ln -s ${nodeModules} ./node_modules
    node ${nodeModules}/webpack-cli/bin/cli.js
  '';
  installPhase = ''
    mkdir -p $out
    cp -r login $out/
  '';
}
