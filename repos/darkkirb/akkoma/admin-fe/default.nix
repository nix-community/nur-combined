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
  python3,
  libsass,
  pkg-config,
  callPackage,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  src = applyPatches {
    src = fetchFromGitea {
      domain = "akkoma.dev";
      owner = "AkkomaGang";
      repo = "admin-fe";
      inherit (source) rev sha256;
    };
    patches = [./admin-fe.patch];
  };
  nodeOptions = callPackage ../../lib/opensslLegacyProvider.nix {};
in
  mkYarnPackage rec {
    pname = "admin-fe";
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

    configurePhase = "cp -r $node_modules node_modules";
    buildPhase = ''
      export NODE_OPTIONS="${nodeOptions}"
      yarn build:prod --offline
    '';
    installPhase = "cp -rv dist $out";
    distPhase = ''
      # (Losslessly) optimise compression of image artifacts
      find $out -type f -name '*.jpg' -execdir ${jpegoptim}/bin/jpegoptim -w$NIX_BUILD_CORES {} \;
      find $out -type f -name '*.png' -execdir ${oxipng}/bin/oxipng -o max -t $NIX_BUILD_CORES {} \;
      find $out -type f -name '*.svg' -execdir ${nodePackages.svgo}/bin/svgo {} \;
    '';
    yarnPreBuild = ''
      mkdir -p $HOME/.node-gyp/${nodejs.version}
      echo 9 > $HOME/.node-gyp/${nodejs.version}/installVersion
      ln -sfv ${nodejs}/include $HOME/.node-gyp/${nodejs.version}
      export npm_config_nodedir=${nodejs}
    '';
    pkgConfig = {
      node-sass = {
        buildInputs = [python3 libsass pkg-config];
        postInstall = ''
          LIBSASS_EXT=auto yarn --offline run build
          rm build/config.gypi
        '';
      };
    };
    passthru = {
      updateScript = writeScript "update-pleroma-fe" ''
        ${../../scripts/update-git.sh} https://akkoma.dev/AkkomaGang/admin-fe.git akkoma/admin-fe/source.json
        SRC_PATH=$(nix-build -E '(import ./. {}).${pname}.src')
        ${../../scripts/update-yarn.sh} $SRC_PATH akkoma/admin-fe
      '';
    };

    meta = with lib; {
      description = "Administration Frontend for Akkoma and Pleroma";
      homepage = "https://akkoma.dev/AkkomaGang/admin-fe/";
      license = licenses.mit;
    };
  }
