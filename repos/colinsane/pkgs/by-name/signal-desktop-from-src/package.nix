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
#
### TODO: build more components from source:
#
# - the dependencies which alpine builds live over here:
#   - <https://github.com/signalapp/libsignal/archive/refs/tags/v$_libsignalver/libsignal-$_libsignalver.tar.gz>
#   - <https://github.com/signalapp/ringrtc/archive/refs/tags/v$_ringrtcver/ringrtc-$_ringrtcver.tar.gz>
#   - <https://s3.sakamoto.pl/lnl-aports-snapshots/webrtc-$_webrtcver.tar.zst>
#   - <https://github.com/signalapp/Signal-FTS5-Extension/archive/refs/tags/v$_stokenizerver/stokenizer-$_stokenizerver.tar.gz>
#
# - nixpkgs packages libsignal-protocol-c, but i think not the actual `libsignal`
#   - <https://github.com/signalapp/libsignal-protocol-c>
# - flare-signal references <https://github.com/signalapp/libsignal>
#   - same with gurk-rs
#   - neither of these do anything special with it.
#   - however, they do refer to it as `name = "libsignal-protocol"`, so maybe libsignal-protocol-c is quite related?
#     - and also `name = "poksho"`, signal-crypto, zkcredential, zkgroup, etc
#
#### better-sqlite
# try:
# - npm rebuild @signalapp/better-sqlite3  --offline
# - npm rebuild @signalapp/better-sqlite3  --offline --nodedir="${nodeSources}" --build-from-source
# - patchelf --add-needed ${icu}/lib/libicutu.so node_modules/@signalapp/better-sqlite3/build/Release/better_sqlite3.node
# or:
# - npm rebuild \
#     @signalapp/better-sqlite3 \
#     sharp spellchecker websocket \
#     utf-8-validate bufferutil fs-xattr \
#     --offline --nodedir="${nodeSources}" --build-from-source
# or:
# - npm_config_nodedir="${nodeSources}" npm_config_node_gyp="${buildPackages.nodejs}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js" npm rebuild --verbose --sqlite=${sqlite.dev} @signalapp/better-sqlite3
#
# or, with nodeSources = srcOnly nodejs';
# - pushd node_modules/@signalapp/better-sqlite3
# - patch -p1 < ${bettersqlitePatch}
# - npm run build-release --offline
# - npm run build-release --offline --nodedir="${nodeSources}"
# - find build -type f -exec \
#     remove-references-to \
#     -t "${nodeSources}" {} \;
# - popd
#
#### ringrtc:
# - readme says that it's going to download webrtc components -- that's probably why Alpine builds that first
# - "To build the Node.js module suitable for including in an Electron app, run:"
#   make electron PLATFORM=<platform> NODEJS_ARCH=<arch>
# - compiling x64 -> arm64 is supported, but arm64 -> arm64 is *not*
# - the referenced file is a 13 MB ELF: /nix/store/7hb6840x2f10zpm3d5ccj3kr3vaf93n5-signal-desktop-6.36.0/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/ringrtc/build/linux/libringrtc-x64.node
# - not in crates.io
#
#### webrtc:
# - nothing much in nixpkgs cites "signalapp", so i probably have to do this manually
# - nothing named `webrtc` linked from the signal-desktop appimage
# - it's like 900MB?? https://s3.sakamoto.pl/lnl-aports-snapshots/webrtc-5845h.tar.zst
# - not in crates.io
#
#
# HOW TO UPDATE
# - `./scripts/update sane.signal-desktop-from-src`
# if using nixpkgs' prebuilds, that's all! else:
# - check signal-desktop's package.json for new ringrtc  <repo:signalapp/Signal-Desktop:package.json>
# - if sqlcipher fails then update sqlcipherTarball url/hash (rare)
# build errors which can be safely ignored:
# - "Error: Could not detect abi for version 30.1.1 and runtime electron.  Updating "node-abi" might help solve this issue if it is a new release of electron"
#   - <https://github.com/signalapp/Signal-Desktop/pull/6889>


{
  alsa-lib,
  asar,
  at-spi2-atk,
  at-spi2-core,
  atk,
  autoPatchelfHook,
  bash,
  buildNpmPackage,
  buildPackages,
  cups,
  electron-bin,
  fetchFromGitHub,
  fetchurl,
  flac,
  gdk-pixbuf,
  git,
  gitUpdater,
  gnused,
  gtk3,
  icu,
  lib,
  libpulseaudio,
  libwebp,
  libxslt,
  makeShellWrapper,
  mesa,
  nix-update-script,
  nspr,
  nss,
  pango,
  python3,
  rsync,
  signal-desktop,
#  sqlite,
#  sqlcipher,
  stdenv,
  wrapGAppsHook,
  xdg-utils,
}:
let
  ringrtcPrebuild = "${signal-desktop}/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/ringrtc";

  betterSqlitePrebuild = "${signal-desktop}/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/better-sqlite3";

  # ringrtcPrebuild = stdenv.mkDerivation {
  #   name = "ringrtc-bin";
  #   src = fetchurl {
  #     # version is found in signal-desktop's package.json as "@signalapp/ringrtc"
  #     url = "https://build-artifacts.signal.org/libraries/ringrtc-desktop-build-v2.48.7.tar.gz";
  #     hash = "sha256-mwCLOIN6frEwVsOCnkAjZAC8YfKK3FZarbZVRTU6SAc=";
  #   };
  #   sourceRoot = ".";
  #   installPhase = ''
  #     mkdir -p $out
  #     cp -R build $out/build
  #   '';
  # };

  # sqlcipherTarball = fetchurl {
  #   # this is a dependency of better-sqlite3.
  #   # version/url is found in <repo:signalapp/better-sqlite3:deps/download.js>
  #   # - checkout the better-sqlite3 tag which matches signal-dekstop's package.json "@signalapp/better-sqlite3" key.
  #   url = let
  #     BETTER_SQLITE3_VERSION = "9.0.8";  #< from Signal-Desktop/package.json
  #     HASH = "b0dbebe5b2d81879984bfa2318ba364fb4d436669ddc1668d2406eaaaee40b7e";
  #     SQLCIPHER_VERSION = "4.6.1-signal-patch2";
  #     EXTENSION_VERSION = "0.2.0";
  #   in "https://build-artifacts.signal.org/desktop/sqlcipher-v2-${SQLCIPHER_VERSION}--${EXTENSION_VERSION}-${HASH}.tar.gz";
  #   hash = "sha256-sNvr5bLYGHmYS/ojGLo2T7TUNmad3BZo0kBuqq7kC34=";
  # };

  # signal-fts5-extension = callPackage ./fts5-extension { };
  # bettersqlitePatch = substituteAll {
  #   # this patch does more than just use the system sqlcipher.
  #   # it also tells bettersqlite to link against its needed runtime dependencies,
  #   # since there's a few statically linked things which aren't called out.
  #   # it also tells bettersqlite not to download sqlcipher when we `npm rebuild`
  #   src = ./bettersqlite-use-system-sqlcipher.patch;
  #   inherit sqlcipher;
  #   inherit (nodejs') libv8;
  #   signal_fts5_extension = signal-fts5-extension;
  # };

  # note that `package.json` locks the electron version, but we seem to not be strictly beholden to that.
  # prefer to use the same electron version as everywhere else, and a `-bin` version to avoid 4hr rebuilds.
  # the non-bin varieties *seem* to ship the wrong `electron.headers` property.
  # - maybe they can work if i manually DL and ship the corresponding headers
  electron' = electron-bin;

  buildNpmArch = if stdenv.buildPlatform.isAarch64 then "arm64" else "x64";
  hostNpmArch = if stdenv.hostPlatform.isAarch64 then "arm64" else "x64";
  crossNpmArchExt = if buildNpmArch == hostNpmArch then "" else "-${hostNpmArch}";
in
buildNpmPackage rec {
  pname = "signal-desktop-from-src";
  version = "7.35.0";

  src = fetchFromGitHub {
    owner = "signalapp";
    repo = "Signal-Desktop";
    leaveDotGit = true;  # signal calculates the release date via `git`
    rev = "v${version}";
    hash = "sha256-swPBAr9OxlcugpT4MQeOi0isWJpDMkkvxvG44Z5Hg28=";
  };

  npmDepsHash = "sha256-OZQlRnnlq4zlmDjqZsPLj3PpzqTrCAGLXGFisMPetBU=";

  patches = [
    # ./debug.patch
    # fix bug that signal launches in the background on wayland
    # - <https://github.com/signalapp/Signal-Desktop/issues/6368>
    # - without this, signal can be started with `signal-desktop & ; sleep 5; signal-desktop`
    #   - the second instance wakes the first one, and then exits
    ./show-on-launch.patch
    # XXX(2024-09-27): not sure what no-mac-screen-share.patch was needed for? build fix? it was introduced by me in 2024-07-xx
    # ./no-mac-screen-share.patch
  ];

  postPatch = ''
    # unpin nodejs. i should probably *try* to keep these vaguely in sync, but it seems to work decently with these out of sync too (at least, if the major versions match?)
    sed -i 's/"node": .*/"node": "*"/' package.json
    # don't populate fallback DNS mappings, and don't try to install electron-builder deps during build:
    substituteInPlace package.json \
      --replace-fail \
        '"build:dns-fallback": "node ts/scripts/generate-dns-fallback.js"' \
        '"build:dns-fallback": "true"' \
      --replace-fail \
        '"electron:install-app-deps": "electron-builder install-app-deps"' \
        '"electron:install-app-deps": "true"'

    # fixes build failure:
    # > Fusing electron at /build/source/release/linux-unpacked/signal-desktop inspect-arguments=false
    # >   ⨯ EACCES: permission denied, open '/build/source/release/linux-unpacked/signal-desktop'  failedTask=build stackTrace=Error: EACCES: permission denied, open '/build/source/release/linux-unpacked/signal-desktop'
    # electron "fusing" (electron.flipFuses) seems to be configuring which functionality electron will support at runtime.
    # notably: ELECTRON_RUN_AS_NODE, cookie encryption, NODE_OPTIONS env var, --inspect-* CLI args, app.asar validation
    # skipping the fuse process seems relatively inconsequential
    substituteInPlace ts/scripts/after-pack.ts \
      --replace-fail 'await fuseElectron' '//await fuseElectron'
  '';

  nativeBuildInputs = [
    asar  # used during fixup
    autoPatchelfHook
    git  # to calculate build date
    gnused
    makeShellWrapper
    python3
    rsync
    wrapGAppsHook
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cups
    electron'
    flac
    gdk-pixbuf
    gtk3
    libpulseaudio
    libwebp
    libxslt
    mesa # for libgbm
    nspr
    nss
    pango
    # so that bettersqlite may link against sqlcipher (see patch)
    # but i don't know if it actually needs to. just copied this from alpine.
    # sqlcipher
  ];

  strictDeps = true;
  # disallowedReferences = [ buildPackages.nodejs ];  #< TODO: set when cross compiling

  # env.SIGNAL_ENV = "production";
  # env.NODE_ENV = "production";  #< XXX setting this causes `node_modules/protobufjs-cli/bin/pbjs` to not be fetched...
  # env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  # env.npm_config_arch = buildNpmArch;
  # env.npm_config_target_arch = hostNpmArch;

  dontWrapGApps = true;
  # dontStrip = false;
  # makeCacheWritable = true;

  npmRebuildFlags = [
    # "--offline"
    "--ignore-scripts"
  ];

  # NIX_DEBUG = 6;

  postConfigure = ''
    # XXX: Signal does not let clients connect if they're running a version that's > 90d old.
    # to calculate the build date, it uses SOURCE_DATE_EPOCH (if set), else `git log`.
    # nixpkgs sets SOURCE_DATE_EPOCH to 1980/01/01 by default, so unset it so Signal falls back to git date.
    # see: Signal-Desktop/ts/scripts/get-expire-time.ts
    export SOURCE_DATE_EPOCH=

    # apparently electron projects aren't "stock" node.
    # so subprojects which want to use node internals (i.e. call C functions provided by node)
    # need to build against electron's versions of the node headers, or something.
    # without patching this, Signal can build, but will fail with `undefined symbol: ...` errors at runtime.
    # see: <https://www.electronjs.org/docs/latest/tutorial/using-native-node-modules>
    tar xzf ${electron'.headers}
    export npm_config_nodedir=$(pwd)/node_headers

    # patchShebangs --build --update node_modules/{bufferutil/node_modules/node-gyp-build/,node-gyp-build,utf-8-validate/node_modules/node-gyp-build}
    # patch these out to remove a runtime reference back to the build bash
    # (better, perhaps, would be for these build scripts to not be included in the asar...)
    substituteInPlace node_modules/dashdash/etc/dashdash.bash_completion.in --replace-fail '#!/bin/bash' '#!/bin/sh'

    # provide necessities which were skipped as part of --ignore-scripts
    rsync -arv ${ringrtcPrebuild}/ node_modules/@signalapp/ringrtc/

    # option 1: replace the entire better-sqlite3 library with the prebuilt version from nixpkgs' signal-desktop
    rsync -arv ${betterSqlitePrebuild}/ node_modules/@signalapp/better-sqlite3/
    # patch so signal doesn't try to *rebuild* better-sqlite3
    substituteInPlace node_modules/@signalapp/better-sqlite3/package.json \
      --replace-fail '"download": "node ./deps/download.js"'  '"download": "true"' \
      --replace-fail '"build-release": "node-gyp rebuild --release"'  '"build-release": "true"' \
      --replace-fail '"install": "npm run download && npm run build-release"'  '"install": "true"'

    # option 2: replace only the sqlcipher plugin with Signal's prebuilt version,
    # and build the rest of better-sqlite3 from source
    # cp $${sqlcipherTarball} node_modules/@signalapp/better-sqlite3/deps/sqlcipher.tar.gz

    # pushd node_modules/@signalapp/better-sqlite3
    #   # node-gyp isn't consistently linked into better-sqlite's `node_modules` (maybe due to version mismatch with signal-desktop's node-gyp?)
    #   PATH="$PATH:$(pwd)/../../.bin" npm --offline run build-release
    # popd

    # pushd node_modules/@signalapp/libsignal-client
    #   npx node-gyp rebuild
    # popd

    # run signal's own `postinstall`:
    # - npm run build:acknowledgments
    # - npm exec patch-package
    # - npm run electron:install-app-deps
    npm run postinstall
  '';

  # excerpts from package.json:
  # - "build": "run-s --print-label generate build:esbuild:prod build:release"
  #   - "generate": "npm-run-all build-protobuf build:esbuild build:dns-fallback build:icu-types build:compact-locales sass get-expire-time copy-components",
  #    - "build-protobuf": "npm run build-module-protobuf",
  #      - "build-module-protobuf": "pbjs --target static-module --force-long --no-typeurl --no-verify --no-create --no-convert --wrap commonjs --out ts/protobuf/compiled.js protos/*.proto && pbts --no-comments --out ts/protobuf/compiled.d.ts ts/protobuf/compiled.js",
  #    - "build:esbuild": "node scripts/esbuild.js",
  #    - "build:dns-fallback": "node ts/scripts/generate-dns-fallback.js",
  #    - "build:icu-types": "node ts/scripts/generate-icu-types.js",
  #    - "build:compact-locales": "node ts/scripts/generate-compact-locales.js",
  #    - "sass": "sass stylesheets/manifest.scss:stylesheets/manifest.css stylesheets/manifest_bridge.scss:stylesheets/manifest_bridge.css",
  #    - "get-expire-time": "node ts/scripts/get-expire-time.js",
  #    - "copy-components": "node ts/scripts/copy.js",
  #  - "build:esbuild:prod": "node scripts/esbuild.js --prod",
  #  - "build:release": "cross-env SIGNAL_ENV=production npm run build:electron -- --config.directories.output=release",
  #    - "build:electron": "electron-builder --config.extraMetadata.environment=$SIGNAL_ENV",
  #
  # i can't call toplevel `build` because some steps fail (e.g. dns-fallback) and can be skipped instead,
  # while other steps fail (electron-builder) and need patching, but npm doesn't plumb the necessary flags through.
  # so instead i call each step individually.

  buildPhase = ''
    runHook preBuild

    npm run generate

    npm run build:esbuild:prod --offline --frozen-lockfile

    npm run build:release -- \
      --${hostNpmArch} \
      --config.electronDist=${electron'}/libexec/electron \
      --config.electronVersion=${electron'.version} \
      --dir

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # directory structure follows the original `signal-desktop` nix package
    mkdir -p $out/lib
    cp -R release/linux${crossNpmArchExt}-unpacked $out/lib/Signal
    # cp -R release/linux-unpacked/resources $out/lib/Signal/resources
    # cp -R release/linux-unpacked/locales $out/lib/Signal/locales

    mkdir $out/bin

    runHook postInstall
  '';

  preFixup = ''
    # fixup the app.asar to:
    # - use host nodejs
    # - use host libpulse.so
    asar extract $out/lib/Signal/resources/app.asar unpacked
    rm $out/lib/Signal/resources/app.asar
    patchShebangs --host --update unpacked
    patchelf --add-needed ${libpulseaudio}/lib/libpulse.so unpacked/node_modules/@signalapp/ringrtc/build/linux/libringrtc-*.node
    asar pack unpacked $out/lib/Signal/resources/app.asar

    # XXX: add --ozone-platform-hint=auto to make it so that NIXOS_OZONE_WL isn't *needed*.
    # electron should auto-detect x11 v.s. wayland: launching with `NIXOS_OZONE_WL=1` is an optional way to force it when debugging.
    # xdg-utils: needed for ozone-platform-hint=auto to work
    # else `LaunchProcess: failed to execvp: xdg-settings`
    makeShellWrapper ${lib.getExe electron'} $out/bin/signal-desktop \
      "''${gappsWrapperArgs[@]}" \
      --add-flags $out/lib/Signal/resources/app.asar \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --add-flags --ozone-platform-hint=auto \
      --add-flags "\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations}" \
      --inherit-argv0
  '';

  passthru = {
    inherit ringrtcPrebuild betterSqlitePrebuild;
    # inherit ringrtcPrebuild sqlcipherTarball;
    # inherit bettersqlitePatch signal-fts5-extension;
    # updateScript = gitUpdater {
    #   rev-prefix = "v";
    #   ignoredVersions = "beta";
    # };
    updateScript = nix-update-script {
      # ignore beta versions
      extraArgs = [ "--version-regex" "v([0-9.]+)" ];
    };
  };

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
