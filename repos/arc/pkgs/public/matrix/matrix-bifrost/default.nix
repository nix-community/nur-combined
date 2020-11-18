{ lib, fetchFromGitHub, runCommand, yarn2nix, nodejs, nodePackages, python2, pidgin, pkg-config, withPurple ? false }: with lib; let
  version = "0.2.0";
  pname = "matrix-bifrost";
  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = pname;
    rev = version;
    sha256 = "1x6gwszs3m6rpk8ps32f589g7lm0izc7vvwvy25rs2qfgkig65c0";
  };
  node-purple-rev = "3ce795053ee6071047d4f57ccc2248680b390476";
  packageJSON = runCommand "package.json" { inherit src; } ''
    substitute $src/package.json $out --replace \
      '"node-purple": "matrix-org/node-purple' \
      '"node-purple": "git+https://github.com/matrix-org/node-purple#${node-purple-rev}' \
      ${optionalString withPurple "--replace optionalPeerDependencies optionalDependencies"}
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
      node-purple = optionalAttrs withPurple {
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
    '' + optionalString withPurple ''
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

      ${optionalString withPurple "export LD_PRELOAD=${pidgin}/lib/libpurple${pidgin.stdenv.hostPlatform.extensions.sharedLibrary}"}
      @nodejs@/bin/node @out@/libexec/@pname@/deps/@pname@/build/src/Program.js "$@"
    '';

    preInstall = ''
      mkdir -p $out/bin
      substituteAll $mainWrapperPath $out/bin/$pname
      chmod +x $out/bin/$pname
    '';

    meta = {
      broken = !(builtins.tryEval yarn2nix).success;
    };
    passthru.ci.omit = true; # derivation name depends on the package json...
  };
in drvExec "bin/${drv.pname}" drv
