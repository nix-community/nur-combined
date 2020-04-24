{ stdenv, mylibs, fetchurl, fetchgit, callPackage, nodePackages, nodejs-10_x }:
let
  nodeEnv = callPackage mylibs.nodeEnv { nodejs = nodejs-10_x; };
  # built using node2nix -8 -l package-lock.json
  # and changing "./." to "src"
  packageEnv = import ./node-packages.nix {
    src = stdenv.mkDerivation (mylibs.fetchedGithub ./iota-cli-app.json // {
      phases = "installPhase";
      installPhase = ''
        cp -a $src $out
        chmod u+w -R $out
        cd $out
        sed -i -e "s@host: 'http://localhost',@host: 'https://nodes.thetangle.org',@" index.js
        sed -i -e "s@port: 14265@port: 443@" index.js
        '';
    });
    inherit fetchurl fetchgit nodeEnv;
  };
in
packageEnv.package
