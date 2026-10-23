# based on https://github.com/Kaliiiiiiiiii-Vinyzu/patchright/blob/main/.github/workflows/patchright_release.yml
#   patchright-workflow:
#     name: "Patchright Release: Install, Patch, Build and Publish Patchright Packages"

# TODO refactor nixpkgs/pkgs/development/web/playwright/driver.nix
# so we can use playwright.overrideAttrs to build patchright

# TODO cleanup

{
  lib,
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
  browsersJSON = (lib.importJSON ./browsers.json).browsers;

  # playwright and patchright use the same versions
  version = "1.64.1";

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

  playwrightSrc = fetchFromGitHub {
    owner = "Microsoft";
    repo = "playwright";
    rev = "v${version}";
    hash = "sha256-oWpJTU3Sob674bLfz0gfHK+vqOoYhK1wmYmVKhsPitM=";
  };

  # patchright-src = fetchFromGitHub {
  src = fetchFromGitHub {
    owner = "Kaliiiiiiiiii-Vinyzu";
    repo = "patchright";
    # tag = "v${finalAttrs.version}";
    tag = "v${version}";
    hash = "sha256-GK0+3eiA7LYkCQgc8iMH/BOOSRQIFUYIGWwHiGqpvNY=";
    fetchSubmodules = true; # patchright-nodejs
  };

  /*
  patchright-nodejs-src = fetchFromGitHub {
    owner = "Kaliiiiiiiiii-Vinyzu";
    repo = "patchright-nodejs";
    # tag = "v${finalAttrs.version}";
    # tag = "v${version}";
    rev = "5d40f66fb35d61d9611d459266a87a3ad7637009";
    hash = "";
  };
  */

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

  # - name: Patch Playwright Driver
  # https://github.com/Kaliiiiiiiiii-Vinyzu/patchright/blob/main/package.json
  # {
  #     "scripts": {
  #         "patch": "cd playwright && tsx ../patchright_driver_patch.ts",
  # patchrightPostPatch = ''
  patchrightPreBuild = ''
    pushd playwright >/dev/null
    # echo "patchrightPostPatch: running patchright_driver_patch.ts"
    echo "patchrightPreBuild: running patchright_driver_patch.ts"
    tsx ../patchright_driver_patch.ts
    # FIXME Error [ERR_MODULE_NOT_FOUND]: Cannot find package 'ts-morph' imported from /build/source/patchright_driver_patch.ts
    popd >/dev/null
  '';

  patchright = buildNpmPackage rec {
    pname = "patchright";
    inherit version src;

    npmDeps = fetchNpmDeps {
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
      name = "${pname}-${version}-npm-deps";
      hash = npmDepsHash;
      # forceGitDeps = false;
      # forceEmptyCache = false;
      # nativeBuildInputs = [ ];
      # fetcherVersion = npmDepsFetcherVersion;
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

      # no, this breaks postUnpack (and postPatch?)
      # sourceRoot = playwrightSourceRoot;

      preBuild = ''
        echo cd $NIX_BUILD_TOP/${playwrightSourceRoot}
        cd $NIX_BUILD_TOP/${playwrightSourceRoot}
      '';

      # name = "${name}-npm-deps";
      # name = "${pname}-${version}-npm-deps";
      name = "${pname}-${version}-playwright-npm-deps";
      hash = playwrightNpmDepsHash;
      # forceGitDeps = false;
      # forceEmptyCache = false;
      # nativeBuildInputs = [ ];
      # fetcherVersion = npmDepsFetcherVersion;
    };

    sourceRoot = "${src.name}"; # update.sh depends on sourceRoot presence
    playwrightSourceRoot = "${src.name}/playwright";

    npmDepsHash = "sha256-qiNMrvhdKlTEcW9vclaVzXOWCEhhLMSeQe8p4ewNITc=";
    playwrightNpmDepsHash = "sha256-a1MGKwKKHYEECsUa4kUlutMMJ8QSeTptBmUPSheIcUg=";

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
    postUnpack = ''
      # FIXME why is $playwrightSourceRoot empty
      # echo "patchright.postUnpack: copying playwright source to $playwrightSourceRoot"
      # cp -r --no-preserve=owner,mode ${playwrightSrc} $playwrightSourceRoot
      # fix: use nix variable ${playwrightSourceRoot}
      echo "patchright.postUnpack: copying playwright source to ${playwrightSourceRoot}"
      cp -r --no-preserve=owner,mode ${playwrightSrc} ${playwrightSourceRoot}

      echo "patchright.postUnpack: adding patchright lockfile: package-lock.json"
      cp ${./package-lock.json} $sourceRoot/package-lock.json
    '';

    postPatch = ''
      pushd playwright >/dev/null
      sed -i '/\/\/ Update test runner./,/^\s*$/{d}' utils/build/build.js
      # The dlopen library check uses ldconfig which doesn't work under Nix.
      # These libraries are already provided via rpath by autoPatchelfHook and wrapProgram.
      # substituteInPlace packages/patchright-core/src/server/registry/index.ts \
      substituteInPlace packages/playwright-core/src/server/registry/index.ts \
        --replace-fail "['libGLESv2.so.2', 'libx264.so']" "[]"
      popd >/dev/null
    '';

    # preBuild = patchrightPreBuild;

    #   ${patchrightPreBuild}
    buildPhase = ''

      if false; then
        # debug
        echo "npmDeps: ${npmDeps}"
        echo "playwrightNpmDeps: ${playwrightNpmDeps}"
        set -x
        pwd
        ls -l -A
        ls -l -A node_modules
        stat node_modules || true
        stat _cacache || true
        exit 1
      fi

      pushd playwright >/dev/null

      echo "Patching Playwright Driver"
      tsx ../patchright_driver_patch.ts

      echo "Generating Playwright Channels"
      # Ignore the error exit code, as the script exits 1 when a file is modified.
      node utils/generate_channels.js || true

      echo "adding playwrightNpmDeps from ${playwrightNpmDeps}"
      # ln -s ${playwrightNpmDeps} node_modules
      ln -s ${playwrightNpmDeps}/_cacache _cacache

      # based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/node/build-npm-package/hooks/npm-config-hook.sh
      # TODO maybe use npmConfigHook or a nested buildNpmPackage to install node_modules
      echo "Installing playwright dependencies"
      npm_config_cache=${playwrightNpmDeps} \
      npm_config_offline="true" \
      npm_config_progress="false" \
      npm ci --ignore-scripts # $npmInstallFlags "''${npmInstallFlagsArray[@]}" $npmFlags "''${npmFlagsArray[@]}"
      patchShebangs node_modules
      npm rebuild # $npmRebuildFlags "''${npmRebuildFlagsArray[@]}" $npmFlags "''${npmFlagsArray[@]}"
      patchShebangs node_modules

      echo "Building Patchright Packages"
      npm run build

      echo "Rebranding Patchright Package"
      npx tsx ../patchright-nodejs/patchright_rebranding.ts

      popd >/dev/null
    '';

    installPhase = ''
      runHook preInstall

      shopt -s extglob

      pushd playwright >/dev/null

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

      popd >/dev/null

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
      updateScript = ./update.sh;
    };
  });

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

  components = {
    chromium = callPackage ./chromium.nix {
      inherit system throwSystem;
      inherit (browsersJSON.chromium) revision browserVersion;
      fontconfig_file = makeFontsConf {
        fontDirectories = [ ];
      };
    };
    chromium-headless-shell = callPackage ./chromium-headless-shell.nix {
      inherit system throwSystem;
      inherit (browsersJSON."chromium-headless-shell") revision browserVersion;
    };
    firefox = callPackage ./firefox.nix {
      inherit system throwSystem;
      inherit (browsersJSON.firefox) revision;
    };
    webkit = callPackage ./webkit.nix {
      inherit system throwSystem;
      inherit (browsersJSON.webkit) revision;
    };
    ffmpeg = callPackage ./ffmpeg.nix {
      inherit system throwSystem;
      inherit (browsersJSON.ffmpeg) revision;
    };
  };

  browsers = lib.makeOverridable (
    {
      withChromium ? true,
      withFirefox ? true,
      withWebkit ? true, # may require `export PATCHRIGHT_HOST_PLATFORM_OVERRIDE="ubuntu-24.04"`
      withFfmpeg ? true,
      withChromiumHeadlessShell ? true,
      fontconfig_file ? makeFontsConf {
        fontDirectories = [ ];
      },
    }:
    let
      browsers =
        lib.optionals withChromium [ "chromium" ]
        ++ lib.optionals withChromiumHeadlessShell [ "chromium-headless-shell" ]
        ++ lib.optionals withFirefox [ "firefox" ]
        ++ lib.optionals withWebkit [ "webkit" ]
        ++ lib.optionals withFfmpeg [ "ffmpeg" ];
    in
    linkFarm "patchright-browsers" (
      lib.listToAttrs (
        map (
          name:
          let
            value = browsersJSON.${name};
          in
          lib.nameValuePair "${lib.replaceStrings [ "-" ] [ "_" ] name}-${value.revision}" components.${name}
        ) browsers
      )
    )
  );
in
{
  patchright-core = patchright-core;
  patchright-test = patchright-test;
}
