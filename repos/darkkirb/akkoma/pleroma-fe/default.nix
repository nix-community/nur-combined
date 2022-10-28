{
  lib,
  mkYarnPackage,
  fetchFromGitea,
  fetchYarnDeps,
  fixup_yarn_lock,
  yarn,
  nodejs,
  jpegoptim,
  oxipng,
  nodePackages,
  writeScript,
  applyPatches,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  src = applyPatches {
    src = fetchFromGitea {
      domain = "akkoma.dev";
      owner = "AkkomaGang";
      repo = "pleroma-fe";
      inherit (source) rev sha256;
    };
    patches = [./pleroma-fe.patch];
  };
  nodeOptions =
    if builtins.compareVersions nodejs.version "18" >= 0
    then "--openssl-legacy-provider"
    else "";
in
  mkYarnPackage rec {
    pname = "pleroma-fe";
    version = source.date;
    inherit src;
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
    yarnNix = ./yarn.nix;

    nativeBuildInputs = [
      jpegoptim
      oxipng
      nodePackages.svgo
    ];
    # Build scripts assume to be used within a Git repository checkout
    patchPhase = ''
      sed -E -i \
        -e '/^let commitHash =/,/;$/clet commitHash = "${builtins.substring 0 7 source.rev}";' \
        build/webpack.prod.conf.js
    '';
    configurePhase = "cp -r $node_modules node_modules";
    buildPhase = ''
      export NODE_OPTIONS="${nodeOptions}"
      yarn build --offline
    '';
    installPhase = "cp -rv dist $out";
    distPhase = ''
      # (Losslessly) optimise compression of image artifacts
      find $out -type f -name '*.jpg' -execdir ${jpegoptim}/bin/jpegoptim -w$NIX_BUILD_CORES {} \;
      find $out -type f -name '*.png' -execdir ${oxipng}/bin/oxipng -o max -t $NIX_BUILD_CORES {} \;
      find $out -type f -name '*.svg' -execdir ${nodePackages.svgo}/bin/svgo {} \;
    '';
    passthru = {
      updateScript = writeScript "update-pleroma-fe" ''
        ${../../scripts/update-git.sh} https://akkoma.dev/AkkomaGang/pleroma-fe.git akkoma/pleroma-fe/source.json
        SRC_PATH=$(nix-build -E '(import ./. {}).${pname}.src')
        ${../../scripts/update-yarn.sh} $SRC_PATH akkoma/pleroma-fe
      '';
    };

    meta = with lib; {
      description = "Frontend for Akkoma and Pleroma";
      homepage = "https://akkoma.dev/AkkomaGang/pleroma-fe/";
      license = licenses.agpl3;
    };
  }
