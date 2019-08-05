{ lib, fetchFromGitHub, runCommand, yarn2nix, nodejs, nodePackages, python2, pidgin, pkg-config }: let
  version = "c6479615a5a621a53125950207f80f65ad349c5a";
  pname = "matrix-bifrost";
  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = pname;
    rev = version;
    sha256 = "05fr3fd34ddwxs56f1gwm07hh4k283sdxi7qg2j4wy9p2ibakcm1";
  };
  node-purple-rev = "3ce795053ee6071047d4f57ccc2248680b390476";
  packageJSON = runCommand "package.json" { inherit src; } ''
    substitute $src/package.json $out --replace \
      '"node-purple": "matrix-org/node-purple' \
      '"node-purple": "git+https://github.com/matrix-org/node-purple#${node-purple-rev}' \
      --replace optionalPeerDependencies optionalDependencies \
      --replace 'htmlparser2": "^3.10.0"' 'htmlparser2": "~3.7.3"' \
      --replace 'htmlparser2": "^3.7.31"' 'htmlparser2": "~3.7.31"'
  '';
  nodeSources = runCommand "node-sources" {} ''
    tar --no-same-owner --no-same-permissions -xf ${nodejs.src}
    mv node-* $out
  '';
  drv = yarn2nix.mkYarnPackage {
    inherit version pname src packageJSON;
    name = "matrix-appservice-purple-${version}";
    yarnLock = ./yarn.lock;
    yarnNix = ./yarn.nix;
    doDist = false;
    distPhase = "true";
    pkgConfig = {
      node-purple = {
        buildInputs = [ nodePackages.node-gyp nodePackages.node-pre-gyp python2 pidgin pkg-config ];

        postInstall = ''
          ln -s ${pidgin}/include deps/pidgin-2.13.0
          ln -s ${pidgin}/include/libpurple deps/libpurple
          patch -p1 < ${./node-purple.patch}
          node-gyp --nodedir ${nodeSources} rebuild
          rm -rf deps
        '';
      };
    };

    postConfigure = ''
      ln -Tsf ../../node_modules deps/$pname/node_modules

      substituteInPlace deps/$pname/src/Program.ts --replace \
        "./config/config.schema.yaml" \
        "$out/libexec/$pname/deps/$pname/config/config.schema.yaml"
      substituteInPlace deps/$pname/src/Config.ts --replace \
        "./node_modules/node-purple/deps/libpurple/" \
        "${pidgin}/lib/purple-2/"
    '';

    buildPhase = ''
      yarn $yarnFlags build
    '';

    nativeBuildInputs = [ nodePackages.node-gyp ];
    inherit nodejs;

    passAsFile = [ "mainWrapper" ];
    mainWrapper = ''
      #!/usr/bin/env bash

      export LD_PRELOAD=${pidgin}/lib/libpurple${pidgin.stdenv.hostPlatform.extensions.sharedLibrary}
      @nodejs@/bin/node @out@/libexec/@pname@/deps/@pname@/build/src/Program.js "$@"
    '';

    preInstall = ''
      mkdir -p $out/bin
      substituteAll $mainWrapperPath $out/bin/$pname
      chmod +x $out/bin/$pname
    '';

    meta = {
      broken = !(builtins.tryEval yarn2nix).success;
      skip.ci = true; # derivation name depends on the package json...
    };
  };
in lib.drvExec "bin/${drv.pname}" drv
