{
  lib,
  stdenv,
  buildNpmPackage,
  copyDesktopItems,
  electron_44,
  fetchFromGitHub,
  makeDesktopItem,
  makeWrapper,
  nodejs_24,
  perl,
  zip,
}:

buildNpmPackage (finalAttrs: {
  pname = "balena-etcher";
  version = "2.1.9";

  src = fetchFromGitHub {
    owner = "balena-io";
    repo = "etcher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4gfnoXJYYwLsTEMNStBCED5hxb060fkuEBYIbDj8bWg=";
  };

  npmDepsHash = "sha256-sbsxeqmbj2Uz3s2u2LLZaro0edSQ2+RhJv5jmFNdlyA=";
  makeCacheWritable = true;
  npmInstallFlags = [ "--ignore-scripts" ];
  npmRebuildFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    nodejs_24
    perl
    zip
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    ELECTRON_SKIP_NOTARIZATION = "1";
    ETCHER_NODE_PATH = "${nodejs_24}/bin/node";
    ETCHER_NODEDIR = "${nodejs_24}";
    npm_config_build_from_source = "true";
  };

  patches = [ ./sidecar-wrapper.patch ];

  dontNpmBuild = true;

  buildPhase = ''
    runHook preBuild

    # electron-forge expects the Electron package to contain its runtime,
    # while Nix provides that runtime separately.
    cp -R ${electron_44.dist} node_modules/electron/dist
    chmod -R u+w node_modules/electron/dist

    export npm_config_nodedir=${electron_44.headers}
    substituteInPlace node_modules/@electron-forge/core-utils/dist/electron-version.js \
      --replace-fail "return version" "return '${electron_44.version}'"

    mkdir -p .electron-packager/electron-zips
    electronPlatform=${stdenv.hostPlatform.node.platform}
    electronArch=${stdenv.hostPlatform.node.arch}
    electronZip="$(pwd)/.electron-packager/electron-zips/electron-v${electron_44.version}-$electronPlatform-$electronArch.zip"
    pushd node_modules/electron/dist
    zip -0Xqr "$electronZip" .
    popd
    substituteInPlace node_modules/@electron/packager/dist/packager.js \
      --replace-fail "await this.getElectronZipPath(downloadOpts)" \
        "'$electronZip'"

    npm exec -- electron-forge package \
      --platform="$electronPlatform" \
      --arch="$electronArch"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    appDir=$(find out -mindepth 1 -maxdepth 1 -type d -name 'balenaEtcher-*' | head -1)
    test -n "$appDir"

    mkdir -p $out/bin
    if [[ "${lib.boolToString stdenv.hostPlatform.isDarwin}" == true ]]; then
      mkdir -p $out/Applications
      cp -R "$appDir/balenaEtcher.app" $out/Applications/
      makeWrapper $out/Applications/balenaEtcher.app/Contents/MacOS/balenaEtcher \
        $out/bin/balena-etcher
    else
      mkdir -p $out/lib/balena-etcher
      cp -R "$appDir"/. $out/lib/balena-etcher/
      makeWrapper $out/lib/balena-etcher/balena-etcher $out/bin/balena-etcher
    fi

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "balena-etcher";
      exec = "balena-etcher %U";
      icon = "balena-etcher";
      desktopName = "balenaEtcher";
      comment = finalAttrs.meta.description;
      categories = [ "Utility" ];
    })
  ];

  postInstall = ''
    install -Dm644 assets/icon.png $out/share/icons/hicolor/512x512/apps/balena-etcher.png
  '';

  meta = {
    description = "Flash OS images to SD cards and USB drives";
    homepage = "https://github.com/balena-io/etcher";
    license = lib.licenses.asl20;
    mainProgram = "balena-etcher";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
