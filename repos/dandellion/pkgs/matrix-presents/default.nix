{ lib, writeText, mkYarnPackage, fetchFromGitHub, nodejs-12_x, jq,  conf ? {} }:

let
  defaultConfig = {
    guest_homeserver = "https://reckless.half-shot.uk";
    base_url = "https://presents.half-shot.uk";
  };
  configOverrideFile = writeText "matri-presents-config-overrides.json" (builtins.toJSON (defaultConfig // conf));
in
mkYarnPackage {
  pname = "matrix-presents";
  version = "unstable-2020-03-04";
  
  #src = fetchFromGitHub {
  #  owner = "Half-Shot";
  #  repo = "matrix-presents";
  #  rev = "7643fc47b7eca0db5e265513c2ecb4ceb58cda78";
  #  sha256 = "1ci0dgbyaghgyxm9wvl77aydj937vg9kajldi8nskx7sd42dv9wj";
  #};

  src = ~/Documents/matrix-presents;

  buildPhase = ''
    cp ${configOverrideFile} deps/matrix-presents/config.json
    ls -alh deps/matrix-presents/node_modules/
    #mkdir -p deps/matrix-presents/node_modules/animate.css
    #cp node_modules/animate.css/animate.css deps/matrix-presents/node_modules/animate.css/animate.css
    yarn build
  '';

  installPhase = ''
    mkdir $out
    cp -r deps/synapse-admin/build/* $out
  '';

  distPhase = "true";
}

