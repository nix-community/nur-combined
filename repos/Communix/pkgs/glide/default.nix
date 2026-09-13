{
  buildMozillaMach,
  fetchFromGitHub,
  lib,
  fetchurl,
  git,
  nodejs,
  pkg-config,
  fetchPnpmDeps,
  pnpm,
  pnpmConfigHook,
  python3,
  stdenv,
}:

let
  glideVersion = "0.1.64a";
  glideRevision = "e89e9a621993";
  firefoxVersion = "156.0b3";

  firefoxSrc = fetchurl {
    url = "mirror://mozilla/firefox/releases/${firefoxVersion}/source/firefox-${firefoxVersion}.source.tar.xz";
    hash = "sha256-9WRZZH1ccXfm3FqxDq/ksG/EKZPa9RPVYZ2VCSqw/eQ=";
  };

  patchedGlideSrc = stdenv.mkDerivation {
    pname = "glide-browser-fix-overrides";
    version = glideVersion;

    src = fetchFromGitHub {
      owner = "glide-browser";
      repo = "glide";
      tag = glideVersion;
      hash = "sha256-T/Sw6HxbCY9qbpa7ALtOQiDkFcsgIZcPXgU5dLE444o=";
    };

    nativeBuildInputs = [ nodejs ];

    postPatch = ''
      # pnpm is a fuck 
      # moves package overrides somewhere else as required by pnpm 11
      node -e "
        const fs = require('fs');
        const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
        if (pkg.pnpm && pkg.pnpm.overrides) {
          pkg.overrides = { ...(pkg.overrides || {}), ...pkg.pnpm.overrides };
          delete pkg.pnpm.overrides;
          if (Object.keys(pkg.pnpm).length === 0) delete pkg.pnpm;
        }
        delete pkg.packageManager;
        fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
      "
      # remove old pnpm overrides section
      sed -i '/^overrides:/,/^$/d' pnpm-lock.yaml
    '';

    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      cp -r . $out
      runHook postInstall
    '';
  };

  patchedSrc = stdenv.mkDerivation (finalAttrs: {
    pname = "firefox-glide-browser-src-patched";
    version = glideVersion;
    GLIDE_REVISION = glideRevision;

    src = patchedGlideSrc;

    postUnpack = ''
      mkdir -p engine
      tar xf ${firefoxSrc} --strip-components=1 -C engine
    '';

    postPatch = ''
      mkdir -p engine
      tar xf ${firefoxSrc} --strip-components=1 -C engine
    '';

    nativeBuildInputs = [
      git
      nodejs
      python3
      pkg-config
      pnpm
      pnpmConfigHook

    ];

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 4;
      hash = "sha256-qczgipxw2lU3qIaIn9xgJATVQV/1ZjWnPmYXNd6jq44=";
    };

    buildPhase = ''
      runHook preBuild

      # replace dprint with a no-op script as it's just used for formatting a
      # generated .d.ts file, which is not worth adding it as a dependency for
      rm node_modules/.bin/dprint
      echo '#!/bin/sh' > node_modules/.bin/dprint
      chmod +x node_modules/.bin/dprint

      patchShebangs scripts/

      pnpm bootstrap --offline
      # bootstrap includes a default mozconfig but that can mess with options that `buildMozillaMach` sets, so just remove it.
      rm engine/mozconfig

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r engine $out

      cd $out
      for i in $(find . -type l); do
        realpath=$(readlink $i)
        rm $i
        cp $realpath $i
      done

      runHook postInstall
    '';

    dontFixup = true;
  });
in
(
  (buildMozillaMach {
    pname = "glide-browser";
    version = firefoxVersion;
    packageVersion = glideVersion;
    applicationName = "Glide";
    binaryName = "glide";
    branding = "browser/branding/glide";

    src = patchedSrc;

    extraConfigureFlags = [
      "--disable-lto"
      "--with-app-basename=Glide"
    ];

    meta = {
      description = "Extensible and keyboard-focused web browser built on Firefox";
      homepage = "https://glide-browser.app/";
      downloadPage = "https://glide-browser.app/#download";
      changelog = "https://glide-browser.app/changelog#${glideVersion}";
      license = lib.licenses.mpl20;
      platforms = lib.platforms.unix;
      mainProgram = "glide";
    };
  }).override
  {
    enablePGO = false;
    enableCrashReporter = false;
    enableAddonSigning = false;
    enableAddonSideload = true;
    enableOfficialBranding = false;
  }
).overrideAttrs
  (
    prev:
    {
      strictDeps = true;
      __structuredAttrs = true;

      GLIDE_FIREFOX_VERSION = firefoxVersion;
      MOZ_USER_DIR = "Glide Browser";

      # these revert patches don't apply.
      patches = lib.filter (
        p:
        !lib.elem (p.name or (baseNameOf p)) [
          "73cbb9ff0fdbf8b13f38d078ce01ef6ec0794f9c.patch"
          "c1cd0d56e047a40afb2a59a56e1fd8043e448e05.patch"
        ]
      ) prev.patches;
    }
    // lib.optionalAttrs stdenv.isDarwin {
      # note: might be redundant
      MOZ_MACBUNDLE_NAME = "Glide.app";
    }
  )
