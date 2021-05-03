{ lib, mkYarnPackage, fetchFromGitHub, nodejs-10_x }:

mkYarnPackage {
  pname = "synapse-admin";
  version = "0.7.0";
  
  src = fetchFromGitHub {
    owner = "Awesome-Technologies";
    repo = "synapse-admin";
    rev = "0.7.0";
    sha256 = "00vqqgchzff231s5kxxsv3yalnmr16q86ycj2nj1m728d3jmi0k1";
  };

  buildPhase = ''
    yarn build
  '';

  installPhase = ''
    mkdir $out
    cp -r deps/synapse-admin/build/* $out
  '';

  distPhase = "true";
}
