{ lib, fetchFromGitHub, runCommand, yarn2nix, nodejs }: let
  version = "0.18.0";
  pname = "markdownlint-cli";
  src = fetchFromGitHub {
    owner = "igorshubovych";
    repo = pname;
    rev = "v${version}";
    sha256 = "1rrmxr3s4bij5ps8chjkw9hkd4hn0fwxwjc3xx6j4qrzjhj39d2a";
  };
  drv = yarn2nix.mkYarnPackage {
    inherit version pname src;
    name = "${pname}-${version}";
    yarnLock = ./yarn.lock;
    yarnNix = ./yarn.nix;
    packageJSON = src + "/package.json";
    doDist = false;
    distPhase = "true";

    yarnPreBuild = ''
      ln -s ${src}/test ./
    '';

    postConfigure = ''
      ln -Tsf ../../node_modules deps/$pname/node_modules
    '';

    meta = {
      broken = !(builtins.tryEval yarn2nix).success;
      skip.ci = true; # derivation name depends on the package json...
    };
  };
in lib.drvExec "bin/${drv.pname}" drv
