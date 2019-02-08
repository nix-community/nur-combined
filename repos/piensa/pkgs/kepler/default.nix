{ stdenv, yarn, python2, nodePackages, nodejs, utillinux, runCommand, writeTextFile, fetchurl, fetchgit }:

let 
  nodeEnv = import ./node-env.nix {
    inherit stdenv python2 utillinux runCommand writeTextFile;
    inherit nodejs;
    libtool = null;
  };
  nodePackages = import ./node-packages.nix {
    inherit fetchurl fetchgit;
    inherit nodeEnv;
  };
  webpack = nodePackages.webpack;
in 
nodeEnv.buildNodePackage {
  packageName = "keplergl";
  name = "keplergl";
  version = "2019-02-07";
  dontNpmInstall = true;
  buildInputs = [ yarn  ];
#  postInstall = ''
#    yarn build:umd
#  '';

  src = fetchgit {
    rev = "5620599c05672c1d04d256679d0ff969aa6d77bb";
    url = "https://github.com/uber/kepler.gl";
    sha256 = "16yn98clq90slcyiaj6qvbfcg1csisjs8gsrn6j0p79alf8lk2hq";
  };
}
