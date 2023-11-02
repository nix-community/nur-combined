# arch package:
# - <https://gitlab.archlinux.org/archlinux/packaging/packages/signal-desktop/-/blob/main/PKGBUILD?ref_type=heads>
# - builds with `yarn generate; yarn build`
# alpine package:
# - <https://gitlab.alpinelinux.org/alpine/aports/-/blob/master/testing/signal-desktop/APKBUILD?ref_type=heads>
# - more involved build process, apparently to reuse deps shared with other parts of the OS:
#   - manually build signal's webrtc using ninja
#   - manually build signal's ringrtc using yarn
#   - manually build libsignal with yarn, cargo and cbindgen
#   - yarn build:acknowledgments
#   - yarn patch-package
#   - npm rebuild esbuild  # apparently esbuild is to be used later in the build process
#   - yarn build:dev
#   - yarn install
#   - then it `mv`s and `patch`s a bunch of stuff
#   - tasje pack
#
# signal uses typescript, javascript, and electron
# - no node, npm
#
# runtime error (temporarily fixed for x64 only, ringrtc):
#   ```
#   Error: Cannot find module '../../build/linux/libringrtc-x64.node'
#   Require stack:
#   - /nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/ringrtc/dist/ringrtc/Native.js
#   - /nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/ringrtc/dist/ringrtc/CallLinks.js
#   - /nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/ringrtc/dist/ringrtc/Service.js
#   - /nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/ringrtc/dist/index.js
#   - /nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/migrations/89-call-history.js
#   - /nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/migrations/index.js
#   - /nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/app/main.js
#   - /nix/store/nqp0wqs8xa2dw36yc6i1lyhnx0m39fsk-electron-unwrapped-27.0.0/libexec/electron/resources/default_app.asar/main.js
#   -
#       at node:internal/modules/cjs/loader:1084:15
#       at Function._resolveFilename (node:electron/js2c/browser_init:2:116646)
#       at node:internal/modules/cjs/loader:929:27
#       at Function._load (node:electron/js2c/asar_bundle:2:13327)
#       at Module.require (node:internal/modules/cjs/loader:1150:19)
#       at require (node:internal/modules/cjs/helpers:121:18)
#       at Object.<anonymous> (/nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/ringrtc/dist/ringrtc/Native.js:33:19)
#       at Module._compile (node:internal/modules/cjs/loader:1271:14)
#       at Object..js (node:internal/modules/cjs/loader:1326:10)
#       at Module.load (node:internal/modules/cjs/loader:1126:32)
#   ```
# - `ringrtc` doesn't exist anywhere inside the installed result -- but that _could_ be because of the asar, or it could be because it doesn't get installed
# - package.json has a `"build"` key, which references ringrtc in the "singleArchFiles" subfield
#   - "singleArchFiles": "node_modules/@signalapp/{libsignal-client/prebuilds/**,ringrtc/build/**}"
#   - maybe this is getting overlooked because of the way i build?
# - `ringrtc` exists in the build dir at `./source/node_modules/@signalapp/ringrtc/`
#   - but no `libringrtc`
#   - and notably, no `node_modules/@signalapp/ringrtc/build` -- which was mentioned in package.json.
#   - so, i probably need to manually build that.
# - nixpkgs `signal-desktop` includes this line, suggesting that the prebuilt distribution includes the referenced ringrtc file:
#   - `patchelf --add-needed ${libpulseaudio}/lib/libpulse.so "$out/lib/${dir}/resources/app.asar.unpacked/node_modules/@signalapp/ringrtc/build/linux/libringrtc-x64.node"`
#
# runtime error (sqlite)
# - ```
#   Unhandled Promise Rejection: Error: Error: Could not locate the bindings file. Tried:
#    → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/build/better_sqlite3.node
#    → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/build/Debug/better_sqlite3.node
#    → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/build/Release/better_sqlite3.node
#    → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/out/Debug/better_sqlite3.node
#    → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/Debug/better_sqlite3.node
#    → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/out/Release/better_sqlite3.node
#    → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/Release/better_sqlite3.node
#    → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/build/default/better_sqlite3.node
#    → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/compiled/18.15.0/linux/x64/better_sqlite3.node
#    → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/addon-build/release/install-root/better_sqlite3.node
#    → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/addon-build/debug/install-root/better_sqlite3.node
#    → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/addon-build/default/install-root/better_sqlite3.node
#    → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/lib/binding/node-v116-linux-x64/better_sqlite3.node
#       at bindings (/nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/bindings/bindings.js:126:9)
#       at new Database (/nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/lib/database.js:48:64)
#       at openAndMigrateDatabase (/nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/Server.js:365:8)
#       at openAndSetUpSQLCipher (/nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/Server.js:383:14)
#       at Object.initialize (/nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/Server.js:419:16)
#       at MessagePort.<anonymous> (/nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/mainWorker.js:84:35)
#       at [nodejs.internal.kHybridDispatch] (node:internal/event_target:735:20)
#       at exports.emitMessage (node:internal/per_context/messageport:23:28)
#       at Worker.<anonymous> (/nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/main.js:62:26)
#       at Worker.emit (node:events:513:28)
#       at MessagePort.<anonymous> (node:internal/worker:234:53)
#       at [nodejs.internal.kHybridDispatch] (node:internal/event_target:735:20)
#       at exports.emitMessage (node:internal/per_context/messageport:23:28)
#   ```
#
#
#
# the dependencies which alpine builds live over here:
# https://github.com/signalapp/libsignal/archive/refs/tags/v$_libsignalver/libsignal-$_libsignalver.tar.gz
# https://github.com/signalapp/ringrtc/archive/refs/tags/v$_ringrtcver/ringrtc-$_ringrtcver.tar.gz
# https://s3.sakamoto.pl/lnl-aports-snapshots/webrtc-$_webrtcver.tar.zst
# https://github.com/signalapp/Signal-FTS5-Extension/archive/refs/tags/v$_stokenizerver/stokenizer-$_stokenizerver.tar.gz
#
# nixpkgs packages libsignal-protocol-c, but i think not the actual `libsignal`
# - <https://github.com/signalapp/libsignal-protocol-c>
# flare-signal references <https://github.com/signalapp/libsignal>
# - same with gurk-rs
# - neither of these do anything special with it.
# - however, they do refer to it as `name = "libsignal-protocol"`, so maybe libsignal-protocol-c is quite related?
#   - and also `name = "poksho"`, signal-crypto, zkcredential, zkgroup, etc
#
# ringrtc:
# - readme says that it's going to download webrtc components -- that's probably why Alpine builds that first
# - "To build the Node.js module suitable for including in an Electron app, run:"
#   make electron PLATFORM=<platform> NODEJS_ARCH=<arch>
# - compiling x64 -> arm64 is supported, but arm64 -> arm64 is *not*
# - the referenced file is a 13 MB ELF: /nix/store/7hb6840x2f10zpm3d5ccj3kr3vaf93n5-signal-desktop-6.36.0/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/ringrtc/build/linux/libringrtc-x64.node
# - not in crates.io
# - TODO: simplest test would be to just copy this out of nixpkgs' signal-desktop
#
# webrtc:
# - nothing much in nixpkgs cites "signalapp", so i probably have to do this manually
# - nothing named `webrtc` linked from the signal-desktop appimage
# - it's like 900MB?? https://s3.sakamoto.pl/lnl-aports-snapshots/webrtc-5845h.tar.zst
# - not in crates.io


{ lib
, buildPackages
, callPackage
# , electron_26
, electron_25
# , electron
, fetchFromGitHub
# , fetchYarnDeps
, fixup_yarn_lock
, makeWrapper
, nodejs
, python3
, signal-desktop
, sqlite
, srcOnly
, stdenv
, yarn
}:
let
  # package.json locks electron to 25.8.4
  # element-desktop uses electron_26
  # nixpkgs has `electron` defaulted to electron_27
  # alpine builds signal-desktop using its default electron version, i.e. 27.0.2
  # for this package, electron_25 seems more stable than 26/27.
  # 27 complains that better-sqlite was built against an incompatible nodejs.
  # 26 simply segfaults.
  # electron = electron_26;
  electron = electron_25;
in
stdenv.mkDerivation rec {
  pname = "signal-desktop-from-src";
  version = "6.36.0";
  src = fetchFromGitHub {
    owner = "signalapp";
    repo = "Signal-Desktop";
    rev = "v${version}";
    hash = "sha256-86x6OeQAMN5vhLaAphnAfSWeRgUh0wAeZFzxue8otDQ=";
  };

  nativeBuildInputs = [
    fixup_yarn_lock
    makeWrapper
    nodejs  # possibly i could instead use nodejs-slim
    python3
    yarn
  ];
  buildInputs = [
    electron
  ];

  # to update:
  # - `cp ~/ref/repos/signalapp/Signal-Desktop/{package.json,yarn.lock} .`
  # - `nix run '.#yarn2nix' > yarn.nix`
  env.yarnOfflineCache = (callPackage ./yarn.nix {}).offline_cache;
  # alternative method, which bypasses yarn2nix
  # env.yarnOfflineCache = fetchYarnDeps {
  #   # this might be IFD: if `nix run '.#check.nur'` fails then inline the lock: `yarnLock = ./yarn.lock`
  #   yarnLock = "${src}/yarn.lock";
  #   hash = "sha256-AXT6p5lgF0M9ckoxiAvT1HaJhUWVtwEOadY4otdeB0Q=";
  # };
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postPatch = ''
    # fixes build failure:
    # > Fusing electron at /build/source/release/linux-unpacked/signal-desktop inspect-arguments=false
    # >   ⨯ EACCES: permission denied, open '/build/source/release/linux-unpacked/signal-desktop'  failedTask=build stackTrace=Error: EACCES: permission denied, open '/build/source/release/linux-unpacked/signal-desktop'
    # electron "fusing" (electron.flipFuses) seems to be configuring which functionality electron will support at runtime.
    # notably: ELECTRON_RUN_AS_NODE, cookie encryption, NODE_OPTIONS env var, --inspect-* CLI args, app.asar validation
    # skipping the fuse process seems relatively inconsequential
    substituteInPlace ts/scripts/after-pack.ts \
      --replace 'await fuseElectron' '//await fuseElectron'
  '';

  configurePhase = ''
    runHook preConfigure

    export HOME=$NIX_BUILD_TOP
    yarn config --offline set yarn-offline-mirror $yarnOfflineCache
    fixup_yarn_lock yarn.lock
    # optional flags:  --no-progress --non-interactive
    # yarn install creates the node_modules/ directory
    yarn install --offline --frozen-lockfile --ignore-scripts --ignore-engines
    patchShebangs node_modules/

    runHook postConfigure
  '';

  # excerpts from package.json:
  # - "build": "run-s --print-label generate build:esbuild:prod build:release"
  #   - "generate": "npm-run-all build-protobuf build:esbuild sass get-expire-time copy-components"
  #     - "build-protobuf": "yarn build-module-protobuf"
  #       - "build-module-protobuf": "pbjs --target static-module --force-long --no-typeurl --no-verify --no-create --wrap commonjs --out ts/protobuf/compiled.js protos/*.proto && pbts --out ts/protobuf/compiled.d.ts ts/protobuf/compiled.js"
  #     - "build:esbuild": "node scripts/esbuild.js"
  #     - "sass": "sass stylesheets/manifest.scss:stylesheets/manifest.css stylesheets/manifest_bridge.scss:stylesheets/manifest_bridge.css"`
  #     - "get-expire-time": "node ts/scripts/get-expire-time.js"
  #     - "copy-components": "node ts/scripts/copy.js"
  #   - "build:esbuild:prod": "node scripts/esbuild.js --prod"
  #   - "build:release": "cross-env SIGNAL_ENV=production yarn build:electron -- --config.directories.output=release"
  #     - "build:electron": "electron-builder --config.extraMetadata.environment=$SIGNAL_ENV"
  #
  # - "build:dev": "run-s --print-label generate build:esbuild:prod"
  #
  # i can't call toplevel `yarn build` because it doesn't properly forward the `--offline` flags where they need to go.
  # instead i call each step individually.

  buildPhase = ''
    runHook preBuild
    echo 'ignore-engines true' > .yarnrc

    # `node-gyp rebuild` is invoked somewhere, and without this it tries to download node headers from electronjs.org
    mkdir -p "$HOME/.node-gyp/${nodejs.version}"
    echo 9 > "$HOME/.node-gyp/${nodejs.version}/installVersion"
    ln -sfv "${nodejs}/include" "$HOME/.node-gyp/${nodejs.version}"
    export npm_config_nodedir=${nodejs}

    # provide the ringrtc (webrtc) dependency. TODO: build this from source
    cp -R ${signal-desktop}/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/ringrtc/build \
      node_modules/@signalapp/ringrtc/
    # provide the sqlite bindings ELF. TODO: build this from source
    cp -R ${signal-desktop}/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/better-sqlite3/build \
      node_modules/@signalapp/better-sqlite3/

    # yarn generate:
    yarn build-module-protobuf --offline --frozen-lockfile --ignore-scripts --ignore-engines
    yarn build:esbuild --offline --frozen-lockfile --ignore-scripts --ignore-engines
    yarn sass
    yarn get-expire-time
    yarn copy-components

    yarn build:esbuild:prod --offline --frozen-lockfile --ignore-scripts --ignore-engines

    yarn build:release \
      ${if stdenv.isDarwin then "--macos" else "--linux"} ${if stdenv.hostPlatform.isAarch64 then "--arm64" else "--x64"} \
      -c.electronDist=${electron}/libexec/electron \
      -c.electronVersion=${electron.version} \
      --dir

    runHook postBuild
  '';

  # preInstall = ''
  #   # Build the sqlite3 package.
  #   npm_config_nodedir="${srcOnly nodejs}" npm_config_node_gyp="${buildPackages.nodejs}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js" npm rebuild --verbose --sqlite=${sqlite.dev} @signalapp/better-sqlite3
  # '';

  installPhase = ''
    runHook preInstall

    # directory structure follows the original `signal-desktop` nix package
    mkdir -p $out/lib/Signal
    cp -R release/linux-unpacked/resources $out/lib/Signal/resources
    cp -R release/linux-unpacked/locales $out/lib/Signal/locales

    makeWrapper ${electron}/bin/electron $out/bin/signal-desktop \
      --add-flags $out/lib/Signal/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --inherit-argv0

    runHook postInstall
  '';

  preFixup = ''
    # the better-sqlite prebuilt by Signal has an implicit dep on libstdc++.so
    patchelf --add-needed ${lib.getLib stdenv.cc.cc}/lib/libstdc++.so "$out/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/better-sqlite3/build/Release/better_sqlite3.node"
  '';

  meta = {
    description = "Private, simple, and secure messenger";
    longDescription = ''
      Signal Desktop is an Electron application that links with your
      "Signal Android" or "Signal iOS" app.
    '';
    homepage = "https://signal.org/";
    changelog = "https://github.com/signalapp/Signal-Desktop/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
  };
}
