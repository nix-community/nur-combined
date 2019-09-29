{ lib, fetchFromGitHub, runCommand, yarn2nix, nodejs, nodePackages, python2, libiconv }: let
  version = "0.13.0";
  pname = "matrix-appservice-irc";
  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = pname;
    rev = version;
    sha256 = "0cpdv7v7i64pzyaxfk9jwin897w7g5qhvlmvbsazsc9w6adg9ja1";
  };
  nodeSources = runCommand "node-sources" {} ''
    tar --no-same-owner --no-same-permissions -xf ${nodejs.src}
    mv node-* $out
  '';
  drv = yarn2nix.mkYarnPackage {
    inherit version pname src;
    name = "${pname}-${version}";
    yarnLock = ./yarn.lock;
    yarnNix = ./yarn.nix;
    doDist = false;
    distPhase = "true";
    pkgConfig = {
      iconv = {
        buildInputs = [ nodePackages.node-gyp python2 libiconv ];
        postInstall = ''
          node-gyp --nodedir ${nodeSources} rebuild
        '';
      };
    };

    postConfigure = ''
      ln -Tsf ../../node_modules deps/$pname/node_modules
    '';

    buildInputs = [ nodejs ];
    inherit nodejs;

    meta = {
      broken = !(builtins.tryEval yarn2nix).success;
      skip.ci = true; # derivation name depends on the package json...
    };
  };
in lib.drvExec "bin/${drv.pname}" drv
