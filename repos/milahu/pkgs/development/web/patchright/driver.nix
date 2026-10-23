# based on https://github.com/Kaliiiiiiiiii-Vinyzu/patchright/blob/main/.github/workflows/patchright_release.yml
#   patchright-workflow:
#     name: "Patchright Release: Install, Patch, Build and Publish Patchright Packages"

# TODO refactor nixpkgs/pkgs/development/web/playwright/driver.nix
# so we can use playwright.overrideAttrs to build patchright

# TODO cleanup

{
  lib,
  playwright,
  buildNpmPackage,
  fetchNpmDeps,
  stdenv,
  chromium,
  ffmpeg,
  jq,
  nodejs,
  fetchFromGitHub,
  linkFarm,
  callPackage,
  makeFontsConf,
  makeWrapper,
  cacert,
  tsx,
}:
let
  inherit (stdenv.hostPlatform) system;

  throwSystem = throw "Unsupported system: ${system}";

  # version = "1.64.1";

  inherit (playwright)
    # playwright and patchright use the same versions
    version
    # these do not depend on playwright (or patchright)
    components
    browsers
    browsersJSON
  ;

  /*
  src = fetchFromGitHub {
    owner = "Microsoft";
    repo = "playwright";
    rev = "v${version}";
    hash = "sha256-oWpJTU3Sob674bLfz0gfHK+vqOoYhK1wmYmVKhsPitM=";
  };

  patchright-src = fetchFromGitHub {
    owner = "Kaliiiiiiiiii-Vinyzu";
    repo = "patchright";
    # tag = "v${finalAttrs.version}";
    tag = "v${version}";
    hash = "";
    fetchSubmodules = true; # patchright-nodejs
  };
  */

  playwrightSrc = playwright.src;

  patchrightSrcHashByVersion = {
    "1.61.0" = "sha256-N07CyFk1NAPQaokPWmEtRrR0Nfnfof/gzwfANusbt88=";
    "1.61.1" = "sha256-XFzPljrzSd46ixd5GJ+MU+a8ZHqTFpK1gvisIH241Ek=";
    "1.64.1" = "sha256-GK0+3eiA7LYkCQgc8iMH/BOOSRQIFUYIGWwHiGqpvNY=";
    # TODO add more versions
  };

  patchrightNpmDepsHashByVersion = {
    "1.61.0" = "sha256-qiNMrvhdKlTEcW9vclaVzXOWCEhhLMSeQe8p4ewNITc=";
    "1.61.1" = "sha256-qiNMrvhdKlTEcW9vclaVzXOWCEhhLMSeQe8p4ewNITc=";
    "1.64.1" = "sha256-qiNMrvhdKlTEcW9vclaVzXOWCEhhLMSeQe8p4ewNITc=";
    # TODO add more versions
  };

  # FIXME error: attribute 'npmDepsHash' missing
  # playwright-core should passthru playwright.npmDepsHash
  playwrightNpmDepsHashByVersion = {
    "1.61.1" = "sha256-DTRhYHRaPlthyRcD2azEIKMPaRwROLuLOdUC27Rk5zM=";
    "1.64.1" = "sha256-a1MGKwKKHYEECsUa4kUlutMMJ8QSeTptBmUPSheIcUg=";
    # TODO add more versions
  };

  patchrightSrc = fetchFromGitHub {
    owner = "Kaliiiiiiiiii-Vinyzu";
    repo = "patchright";
    # tag = "v${finalAttrs.version}";
    tag = "v${version}";
    hash = patchrightSrcHashByVersion.${version} or (
      builtins.trace ''
        patchright: TODO add hash to patchrightSrcHashByVersion:
          patchrightSrcHashByVersion = {
            "${version}" = "TODO_hash";
          };
      ''
      "" # empty hash
    );
    fetchSubmodules = true; # patchright-nodejs
  };

  /*
  patchrightPostUnpack = ''
    mv $sourceRoot playwright
    cp -r --no-preserve=owner,mode ${patchright-src} $sourceRoot
    mv playwright $sourceRoot
    # ln -s .. $sourceRoot/patchright-python/playwright-python
  '';
  */

  /*
  patchrightPostUnpack = ''
    echo "patchrightPostUnpack: copying playwright source to $sourceRoot/playwright"
    cp -r --no-preserve=owner,mode ${playwrightSrc} $sourceRoot/playwright

    echo "patchrightPostUnpack: adding patchright lockfile: package-lock.json"
    cp ${./package-lock.json} $sourceRoot/package-lock.json
  '';
  */

  /*
  patchrightPrePatch = ''
    echo "patchrightPrePatch: copying playwright source to playwright"
    cp -r --no-preserve=owner,mode ${playwrightSrc} playwright
  '';
  */

  /*
  # - name: Patch Playwright Driver
  # npm run patch
  # https://github.com/Kaliiiiiiiiii-Vinyzu/patchright/blob/main/package.json
  # {
  #     "scripts": {
  #         "patch": "cd playwright && tsx ../patchright_driver_patch.ts",
  # patchrightPostPatch = ''
  patchrightPreBuild = ''
    # pushd playwright
    # echo "patchrightPostPatch: running patchright_driver_patch.ts"
    echo "patchrightPreBuild: running patchright_driver_patch.ts"
    tsx patchright/patchright_driver_patch.ts
    # FIXME Error [ERR_MODULE_NOT_FOUND]: Cannot find package 'ts-morph' imported from /build/source/patchright_driver_patch.ts
    # popd
  '';
  */

  patchright = buildNpmPackage rec {
    pname = "patchright";
    inherit version;

    patchrightNpmDeps = fetchNpmDeps {
      inherit
        # FIXME all `stdenv.mkDerivation` attributes should be inherited from buildNpmPackage to fetchNpmDeps
        # https://github.com/milahu/nixpkgs/issues/113
        src
        # srcs
        sourceRoot
        postUnpack
        # prePatch
        # patches
        postPatch
        # patchFlags
        nativeBuildInputs
      ;
      # name = "${name}-npm-deps";
      # name = "${pname}-${version}-npm-deps";
      name = "${pname}-${version}-patchright-npm-deps";
      hash = patchrightNpmDepsHash;
      # forceGitDeps = false;
      # forceEmptyCache = false;
      # nativeBuildInputs = [ ];
      # fetcherVersion = npmDepsFetcherVersion;

      preBuild = ''
        pushd $NIX_BUILD_TOP/${patchrightSourceRoot}

        # debug
        set -x
        pwd
        ls
        stat package-lock.json
      '';
    };

    playwrightNpmDeps = fetchNpmDeps {
      inherit
        # FIXME all `stdenv.mkDerivation` attributes should be inherited from buildNpmPackage to fetchNpmDeps
        # https://github.com/milahu/nixpkgs/issues/113
        src
        # srcs
        sourceRoot
        postUnpack
        # prePatch
        # patches
        postPatch
        # patchFlags
        nativeBuildInputs
      ;

      preBuild = ''
        pushd $NIX_BUILD_TOP/${playwrightSourceRoot}

        # debug
        set -x
        pwd
        ls
        stat package-lock.json
      '';

      /*
      preBuild = ''
        # debug
        set -x
        pwd
        ls
        stat package-lock.json || true
      '';
      */

      # no, this breaks postUnpack (and postPatch?)
      # sourceRoot = playwrightSourceRoot;

      # old
      /*
      preBuild = ''
        echo cd $NIX_BUILD_TOP/${playwrightSourceRoot}
        cd $NIX_BUILD_TOP/${playwrightSourceRoot}
      '';
      */

      # name = "${name}-npm-deps";
      # name = "${pname}-${version}-npm-deps";
      name = "${pname}-${version}-playwright-npm-deps";
      hash = playwrightNpmDepsHash;
      # hash = npmDepsHash;
      # forceGitDeps = false;
      # forceEmptyCache = false;
      # nativeBuildInputs = [ ];
      # fetcherVersion = npmDepsFetcherVersion;
    };

    # sourceRoot = "${src.name}"; # update.sh depends on sourceRoot presence

    # fail?
    # # the main source tree is playwrightSrc
    # src = playwrightSrc;
    # sourceRoot = playwrightSourceRoot;
    # playwrightSourceRoot = "${src.name}";
    # patchrightSourceRoot = "${src.name}/patchright";
    # npmDeps = playwrightNpmDeps;
    # npmDepsHash = playwrightNpmDepsHash;

    # the main source tree is patchrightSrc
    src = patchrightSrc;
    sourceRoot = patchrightSourceRoot; # update.sh depends on sourceRoot presence
    patchrightSourceRoot = "${src.name}";
    playwrightSourceRoot = "${src.name}/playwright";
    npmDeps = patchrightNpmDeps;
    npmDepsHash = patchrightNpmDepsHash;

    # npmDepsHash = patchrightNpmDepsHashByVersion.${version} or (
    patchrightNpmDepsHash = patchrightNpmDepsHashByVersion.${version} or (
      builtins.trace ''
        patchright: TODO add hash to patchrightNpmDepsHashByVersion:
          patchrightNpmDepsHashByVersion = {
            "${version}" = "TODO_hash";
          };
      ''
      "" # empty hash
    );

    # playwrightNpmDepsHash = "sha256-a1MGKwKKHYEECsUa4kUlutMMJ8QSeTptBmUPSheIcUg=";

    # FIXME error: attribute 'npmDepsHash' missing
    # playwright-core should passthru playwright.npmDepsHash
    # nixpkgs: pkgs/development/web/playwright/driver.nix
    # a: inherit (playwright) version src meta;
    # b: inherit (playwright) version src meta npmDepsHash;
    #
    # playwrightNpmDepsHash = playwright.npmDepsHash;
    #
    # npmDepsHash = playwrightNpmDepsHashByVersion.${version} or (
    playwrightNpmDepsHash = playwrightNpmDepsHashByVersion.${version} or (
      builtins.trace ''
        patchright: TODO add hash to playwrightNpmDepsHashByVersion:
          playwrightNpmDepsHashByVersion = {
            "${version}" = "TODO_hash";
          };
      ''
      "" # empty hash
    );

    nativeBuildInputs = [
      cacert
      jq
      tsx
    ];

    env.ELECTRON_SKIP_BINARY_DOWNLOAD = true;

    # FIXME buildNpmPackage ignores postUnpack
    # workaround: use prePatch or postPatch
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/node/build-npm-package/default.nix
    # https://github.com/NixOS/nixpkgs/issues?q=buildNpmPackage+postUnpack
    # https://github.com/NixOS/nixpkgs/issues/352941
    # Investigating the behaviour of dependency fetchers and builders that use them
    #
    # postUnpack = patchrightPostUnpack;
    # prePatch = patchrightPrePatch;

    # patchright.src is the main source tree
    postUnpack = ''
      # FIXME why is $playwrightSourceRoot empty
      # echo "patchright.postUnpack: copying playwright source to $playwrightSourceRoot"
      # cp -r --no-preserve=owner,mode ${playwrightSrc} $playwrightSourceRoot
      # fix: use nix variable ${playwrightSourceRoot}
      echo "patchright.postUnpack: copying playwright source to ${playwrightSourceRoot}"
      cp -r --no-preserve=owner,mode ${playwrightSrc} ${playwrightSourceRoot}

      echo "patchright.postUnpack: adding patchright lockfile: $sourceRoot/package-lock.json"
      cp ${./package-lock.json} $sourceRoot/package-lock.json
    '';

    # fail?
    # the main source tree is playwrightSrc
    /*
    postUnpack = ''
      echo "patchright.postUnpack: copying patchright source to ${patchrightSourceRoot}"
      cp -r --no-preserve=owner,mode ${patchrightSrc} ${patchrightSourceRoot}

      echo "patchright.postUnpack: adding patchright lockfile: ${patchrightSourceRoot}/package-lock.json"
      cp ${./package-lock.json} ${patchrightSourceRoot}/package-lock.json
    '';
    */

    # old
    /*
    postPatch = ''
      pushd playwright
      ${playwright.postPatch}
      popd
    '';
    */

    # FIXME playwright-driver should passthru "playwright = buildNpmPackage { ... }"
    # so we can use playwright.postPatch
    # postPatch = playwright-driver.postPatch;
    postPatch = "";

    # preBuild = patchrightPreBuild;

    #   ${patchrightPreBuild}
    buildPhase = ''

      if false; then
        # debug
        echo "npmDeps: ${npmDeps}"
        echo "patchrightNpmDeps: ${patchrightNpmDeps}"
        set -x
        pwd
        ls -l -A
        ls -l -A node_modules
        stat node_modules || true
        stat _cacache || true
        exit 1
      fi

      if false; then
      # fail?
      # the main source tree is playwrightSrc
      echo "Installing Patchright Dependencies"
      pushd $NIX_BUILD_TOP/${patchrightSourceRoot}
      # based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/node/build-npm-package/hooks/npm-config-hook.sh
      # TODO maybe use npmConfigHook or a nested buildNpmPackage to install node_modules
      npm_config_cache=${patchrightNpmDeps} \
      npm_config_offline="true" \
      npm_config_progress="false" \
      npm ci --ignore-scripts # $npmInstallFlags "''${npmInstallFlagsArray[@]}" $npmFlags "''${npmFlagsArray[@]}"
      patchShebangs node_modules
      npm rebuild # $npmRebuildFlags "''${npmRebuildFlagsArray[@]}" $npmFlags "''${npmFlagsArray[@]}"
      patchShebangs node_modules
      popd
      else
      # the main source tree is patchrightSrc
      echo "Installing Playwright Dependencies"
      pushd $NIX_BUILD_TOP/${playwrightSourceRoot}
      # based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/node/build-npm-package/hooks/npm-config-hook.sh
      # TODO maybe use npmConfigHook or a nested buildNpmPackage to install node_modules
      npm_config_cache=${playwrightNpmDeps} \
      npm_config_offline="true" \
      npm_config_progress="false" \
      npm ci --ignore-scripts # $npmInstallFlags "''${npmInstallFlagsArray[@]}" $npmFlags "''${npmFlagsArray[@]}"
      patchShebangs node_modules
      npm rebuild # $npmRebuildFlags "''${npmRebuildFlagsArray[@]}" $npmFlags "''${npmFlagsArray[@]}"
      patchShebangs node_modules
      popd
      fi

      pushd $NIX_BUILD_TOP/${playwrightSourceRoot}

      # TODO verify: does this use patchright/node_modules
      # if not, we have to make patchright the main source tree

      echo "Patching Playwright Driver"
      tsx $NIX_BUILD_TOP/${patchrightSourceRoot}/patchright_driver_patch.ts

      echo "Generating Playwright Channels"
      # Ignore the error exit code, as the script exits 1 when a file is modified.
      node utils/generate_channels.js || true



      # /nix/store/7calrqq637bikad9jamsql3dhz3lx7f4-source/./pkgs/development/web/playwright/driver.nix
      # postPatch
      sed -i '/\/\/ Update test runner./,/^\s*$/{d}' utils/build/build.js
      # The dlopen library check uses ldconfig which doesn't work under Nix.
      # These libraries are already provided via rpath by autoPatchelfHook and wrapProgram.
      substituteInPlace packages/playwright-core/src/server/registry/index.ts \
        --replace-fail "['libGLESv2.so.2', 'libx264.so']" "[]"



      echo "Building Patchright Packages"
      # FIXME playwright-core is not installed
      # ==== Running npm ci --save=false --fund=false --audit=false in /build/source/tests/playwright-test/stable-test-runner
      # npm error code ENOTCACHED
      # npm error request to https://registry.npmjs.org/playwright-core/-/playwright-core-1.61.0-alpha-1781023400000.tgz failed
      npm run build

      echo "Rebranding Patchright Package"
      npx tsx $NIX_BUILD_TOP/${patchrightSourceRoot}/patchright-nodejs/patchright_rebranding.ts

      popd
    '';

    installPhase = ''
      runHook preInstall

      shopt -s extglob

      pushd playwright

      mkdir -p "$out/lib/node_modules/patchright"
      cp -r packages/patchright/!(bundles|src|node_modules|.*) "$out/lib/node_modules/patchright"

      # Nixpkgs packages only the top-level browser revisions. Remove platform-specific
      # overrides so patchright selects the revisions available in the browser link farm.
      jq 'del(.browsers[].revisionOverrides)' \
        packages/patchright-core/browsers.json > browser.json.tmp && mv browser.json.tmp packages/patchright-core/browsers.json
      mkdir -p "$out/lib/node_modules/patchright-core"
      cp -r packages/patchright-core/!(bundles|src|bin|.*) "$out/lib/node_modules/patchright-core"

      # there is no patchright-test package
      # mkdir -p "$out/lib/node_modules/@patchright/test"
      # cp -r packages/patchright-test/* "$out/lib/node_modules/@patchright/test"

      popd

      runHook postInstall
    '';

    meta = {
      description = "Framework for Web Testing and Automation";
      homepage = "https://patchright.dev";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [
        kalekseev
      ];
      inherit (nodejs.meta) platforms;
    };
  };

  patchright-core = stdenv.mkDerivation (finalAttrs: {
    pname = "patchright-core";
    inherit (patchright) version src meta;
    inherit (patchright) postUnpack postPatch;
    # inherit (patchright) prePatch postPatch;

    installPhase = ''
      runHook preInstall

      cp -r ${patchright}/lib/node_modules/patchright-core "$out"

      runHook postInstall
    '';

    passthru = {
      inherit browsersJSON;
      selectBrowsers = browsers;
      browsers = browsers { };
      browsers-chromium = browsers {
        withFirefox = false;
        withWebkit = false;
        withChromiumHeadlessShell = false;
      };
      tests.browser-downloads = callPackage ./browser-downloads-test.nix {
        patchright-core = finalAttrs.finalPackage;
      };
      inherit components;
      # updateScript = ./update.sh;
    };
  });

  /*
  patchright-test = stdenv.mkDerivation (finalAttrs: {
    pname = "patchright-test";
    inherit (patchright) version src;
    inherit (patchright) postUnpack postPatch;
    # inherit (patchright) prePatch postPatch;

    nativeBuildInputs = [ makeWrapper ];
    installPhase = ''
      runHook preInstall

      shopt -s extglob
      mkdir -p $out/bin
      cp -r ${patchright}/* $out

      makeWrapper "${nodejs}/bin/node" "$out/bin/patchright" \
        --add-flags "$out/lib/node_modules/@patchright/test/cli.js" \
        --prefix NODE_PATH : ${placeholder "out"}/lib/node_modules \
        --set-default patchright_BROWSERS_PATH "${patchright-core.passthru.browsers}"

      runHook postInstall
    '';

    meta = patchright.meta // {
      mainProgram = "patchright";
    };
  });
  */
in
{
  patchright-core = patchright-core;
  # patchright-test = patchright-test;
}
