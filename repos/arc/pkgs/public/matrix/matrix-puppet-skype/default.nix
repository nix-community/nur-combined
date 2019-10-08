{ lib, fetchFromGitHub, yarn2nix }: let
  rev = "d6fa1acb978ec152f2aae02e78df0264fa10da91";
  pname = "matrix-puppet-skype";
  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = pname;
    inherit rev;
    sha256 = "1a507mlgsmhj0xqm3zyyppbp7ifyb6vdxwpzjqjp5815hfj28rkw";
  };
  version = rev;
  drv = yarn2nix.mkYarnPackage {
    inherit version pname src;
    name = "${pname}-${version}";
    packageJSON = src + "/package.json";
    yarnLock = src + "/yarn.lock";
    yarnNix = ./yarn.nix;
    doDist = false;
    distPhase = "true";

    postConfigure = ''
      ln -Tsf ../../node_modules deps/$pname/node_modules
    '';

    meta = {
      broken = !(builtins.tryEval yarn2nix).success;
    };
    passthru.ci.omit = true; # derivation name depends on the package json...
  };
in lib.drvExec "bin/${drv.pname}" drv
