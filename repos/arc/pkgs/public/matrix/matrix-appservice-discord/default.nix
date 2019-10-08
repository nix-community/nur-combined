{ lib, fetchFromGitHub, runCommand, yarn2nix, nodejs, nodePackages, python2 }: let
  version = "0.5.1";
  pname = "matrix-appservice-discord";
  src = fetchFromGitHub {
    owner = "Half-Shot";
    repo = pname;
    rev = "v${version}";
    sha256 = "1yj2zjicya91qqvlxxzssd4l3wiaxagjyc2y9ar554hr4k0pgh9y";
  };
  packageJSON = runCommand "package.json" { inherit src; } ''
    substitute $src/package.json $out --replace \
      '"matrix-appservice-bridge": "matrix-org/' \
      '"matrix-appservice-bridge": "git+https://github.com/matrix-org/'
  '';
  nodeSources = runCommand "node-sources" {} ''
    tar --no-same-owner --no-same-permissions -xf ${nodejs.src}
    mv node-* $out
  '';
  drv = yarn2nix.mkYarnPackage {
    inherit version pname src packageJSON;
    name = "${pname}-${version}";
    yarnLock = ./yarn.lock;
    yarnNix = ./yarn.nix;
    doDist = false;
    distPhase = "true";
    pkgConfig = {
      better-sqlite3 = {
        buildInputs = [ nodePackages.node-gyp python2 ];
        postInstall = ''
          node-gyp --nodedir ${nodeSources} rebuild
        '';
      };
      integer = {
        buildInputs = [ nodePackages.node-gyp python2 ];
        postInstall = ''
          node-gyp --nodedir ${nodeSources} rebuild
        '';
      };
    };

    postConfigure = ''
      ln -Tsf ../../node_modules deps/$pname/node_modules

      substituteInPlace deps/$pname/src/discordas.ts --replace \
        "./config/config.schema.yaml" \
        "$out/libexec/$pname/deps/$pname/config/config.schema.yaml"
    '';

    buildPhase = ''
      yarn $yarnFlags build
    '';

    buildInputs = [ nodejs ];
    inherit nodejs;

    passAsFile = [ "mainWrapper" ];
    mainWrapper = ''
      #!/usr/bin/env bash

      @nodejs@/bin/node @out@/libexec/@pname@/deps/@pname@/build/@main@.js "$@"
    '';

    preInstall = ''
      mkdir -p $out/bin
      main=src/discordas substituteAll $mainWrapperPath $out/bin/$pname
      main=tools/addbot substituteAll $mainWrapperPath $out/bin/$pname-addbot
      main=tools/adminme substituteAll $mainWrapperPath $out/bin/$pname-adminme
      main=tools/userClientTools substituteAll $mainWrapperPath $out/bin/$pname-usertool
      main=tools/addRoomsToDirectory substituteAll $mainWrapperPath $out/bin/$pname-directoryfix
      main=tools/ghostfix substituteAll $mainWrapperPath $out/bin/$pname-ghostfix
      main=tools/chanfix substituteAll $mainWrapperPath $out/bin/$pname-chanfix
      chmod +x $out/bin/*
    '';

    meta = {
      broken = !(builtins.tryEval yarn2nix).success;
    };
    passthru.ci.omit = true; # derivation name depends on the package json...
  };
in lib.drvExec "bin/${drv.pname}" drv
