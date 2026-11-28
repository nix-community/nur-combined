{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  electron_44,
  yarn,
  python3,
  node-gyp,
  makeWrapper,
  writableTmpDirAsHomeHook,
  pkg-config,
  writeShellApplication,
  nix-update-script,
}:

let
  electron = electron_44;
  nodejs = nodejs_24;
in
buildNpmPackage (finalAttrs: {
  pname = "electerm";
  version = "5.20.0";

  src = fetchFromGitHub {
    owner = "electerm";
    repo = "electerm";
    rev = "v${finalAttrs.version}";
    hash = "sha256-e5N6fwZ26WN5kPIg4pdyecg5/tSSQbLOM5SbVlEgf6k=";
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-C4x2q9FdTI71CdcLd4G2nJg1Q1yNh+2MKCq0qp4Vae8=";

  inherit nodejs;

  makeCacheWritable = true;

  # The renderer comes from upstream's vite build, not the package.json build
  # script, so drive the build from buildPhase below.
  dontNpmBuild = true;

  # The root tree is only build tooling; the production tree that ships is
  # installed into work/app by upstream's prepare step.
  # electron-builder declares optional peer dependencies (squirrel-windows) that
  # the offline cache does not carry; skip peer resolution for the build tree.
  npmFlags = [
    "--ignore-scripts"
    "--legacy-peer-deps"
  ];

  nativeBuildInputs = [
    nodejs
    yarn
    python3
    node-gyp
    pkg-config
    makeWrapper
    writableTmpDirAsHomeHook
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    CSC_IDENTITY_AUTO_DISCOVERY = "false";
    npm_config_build_from_source = "true";
    npm_config_audit = "false";
    npm_config_fund = "false";
  };

  # prepare.js re-installs the production dependency subset into work/app.
  # Resolve it from the prefetched npm cache instead of the network.
  postPatch = ''
    substituteInPlace src/build/bin/prepare.js \
      --replace-fail 'cd work/app && npm i --omit=dev' 'cd work/app && npm i --offline --omit=dev --legacy-peer-deps'
  '';

  buildPhase = ''
    runHook preBuild

    # Rebuild node-pty/serialport/font-list against Electron's ABI without
    # downloading headers.
    export ELECTRON_HEADERS_DIR="$PWD/.electron-headers"
    mkdir -p "$ELECTRON_HEADERS_DIR"
    cp -R ${electron.headers}/include "$ELECTRON_HEADERS_DIR"/
    for gypi in common.gypi config.gypi; do
      if [ -e "$ELECTRON_HEADERS_DIR/include/node/$gypi" ]; then
        ln -s "$ELECTRON_HEADERS_DIR/include/node/$gypi" "$ELECTRON_HEADERS_DIR/$gypi"
      fi
    done
    export npm_config_nodedir="$ELECTRON_HEADERS_DIR"

    # Upstream's own build pipeline: vite bundles, static assets and pug pages,
    # then the production dependency tree under work/app.
    npm run b
    npm run pb

    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    ./node_modules/.bin/electron-builder \
      --mac --arm64 --dir \
      -c.electronDist="$PWD/electron-dist" \
      -c.electronVersion=${electron.version} \
      -c.npmRebuild=false \
      -c.publish=never \
      -c.mac.identity=null

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    appDir=$(echo dist/mac*/*.app | head -1)
    if [ ! -d "$appDir" ]; then
      echo "error: packaged electerm app not found in dist/" >&2
      find dist -maxdepth 3 -type d || true
      exit 1
    fi

    mkdir -p "$out/Applications" "$out/bin"
    cp -R "$appDir" "$out/Applications/Electerm.app"
    ln -s "$out/Applications/Electerm.app/Contents/MacOS/electerm" "$out/bin/electerm"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    app="$out/Applications/Electerm.app"
    test -x "$app/Contents/MacOS/electerm"
    test -f "$app/Contents/Resources/app.asar"
    test -f "$app/Contents/Resources/app.asar.unpacked/node_modules/node-pty/build/Release/pty.node"
    test -f "$app/Contents/Resources/app.asar.unpacked/node_modules/node-pty/build/Release/spawn-helper"
    # /usr/bin/plutil is not executable in the default build sandbox.
    python3 -c "import plistlib, sys; d = plistlib.load(open(sys.argv[1], 'rb')); sys.exit(0 if d['CFBundleShortVersionString'] == sys.argv[2] else 1)" \
      "$app/Contents/Info.plist" "${finalAttrs.version}"

    runHook postInstallCheck
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-electerm";
    text = ''
      export UPDATE_NIX_ATTR_PATH="electerm"
      exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
    '';
  };

  meta = {
    description = "Terminal, SSH, SFTP, telnet, serial, RDP, VNC and ftp client";
    homepage = "https://electerm.org";
    downloadPage = "https://github.com/electerm/electerm/releases";
    changelog = "https://github.com/electerm/electerm/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "electerm";
  };
})
