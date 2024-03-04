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
# - TODO: simplest test would be to just copy this out of nixpkgs' signal-desktop
#
#### webrtc:
# - nothing much in nixpkgs cites "signalapp", so i probably have to do this manually
# - nothing named `webrtc` linked from the signal-desktop appimage
# - it's like 900MB?? https://s3.sakamoto.pl/lnl-aports-snapshots/webrtc-5845h.tar.zst
# - not in crates.io
#
#
# HOW TO UPDATE
# - `nix run '.#update.pkgs.signal-desktop-from-src'`
# - delete `env.yarnOfflineCache.hash` and rebuild it


{ lib
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, autoPatchelfHook
, bash
, buildPackages
, cups
, electron_27-bin
, fetchurl
, fetchFromGitHub
, fetchYarnDeps
, flac
, fixup_yarn_lock
, gdk-pixbuf
, git
, gitUpdater
, gnused
, gtk3
, icu
, libpulseaudio
, libwebp
, libxslt
, makeShellWrapper
, mesa
, nodejs_18
, nspr
, nss
, pango
, python3
# , sqlite
# , sqlcipher
, stdenv
, wrapGAppsHook
, xdg-utils
, yarn
}:
let
  version = "7.0.0";

  ringrtcPrebuild = fetchurl {
    # version is found in signal-desktop's package.json as "@signalapp/ringrtc"
    url = "https://build-artifacts.signal.org/libraries/ringrtc-desktop-build-v2.36.0.tar.gz";
    hash = "sha256-BIp+2V0PVmRqAA4mXt28utAMOAY4GrRELP8tfETf3Ns=";
  };
  sqlcipherTarball = fetchurl {
    # this is a dependency of better-sqlite3.
    # version/url is found in <repo:https://github.com/signalapp/better-sqlite3:deps/download.js>
    # - checkout the better-sqlite3 tag which matches signal-dekstop's package.json "@signalapp/better-sqlite3" key.
    url = "https://build-artifacts.signal.org/desktop/sqlcipher-4.5.5-fts5-fix--3.0.7--0.2.1-ef53ea45ed92b928ecfd33c552d8d405263e86e63dec38e1ec63e1b0193b630b.tar.gz";
    hash = "sha256-71PqRe2SuSjs/TPFUtjUBSY+huY97Djh7GPhsBk7Yws=";
  };

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

  src = fetchFromGitHub {
    owner = "signalapp";
    repo = "Signal-Desktop";
    leaveDotGit = true;  # signal calculates the release date via `git`
    rev = "v${version}";
    hash = "sha256-iIPDUMFGL2a6JKblSTY05nPSDhF4b4AvyO2k0NY9UJE=";
  };
  mkNodeJs = nodejs: nodejs.overrideAttrs (upstream:
    let
      # build with the same nodejs upstream expects in package.json (it will error if the version here is incorrect)
      version = "18.18.2";
      hash = "sha256-ckni8K+UPsOFmVBPSyor0x+5OHhykbbMymyLrfAeO1Y=";
    in {
      inherit version;
      src = fetchurl {
        url = "https://nodejs.org/dist/v${version}/node-v${version}.tar.xz";
        inherit hash;
      };
    }
  );
  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    hash = "sha256-+IFzjTv3ghyFu0MRca2SO+tzeQPJGVW/KyWf7SdCmtQ=";
  };

  nodejs' = mkNodeJs nodejs_18;
  # TODO: possibly i could instead use nodejs-slim (npm-less nodejs)
  buildNodejs = mkNodeJs buildPackages.nodejs_18;

  buildYarn = buildPackages.yarn.override { nodejs = buildNodejs; };

  # package.json locks electron to 25.y.z
  # element-desktop uses electron_26
  # nixpkgs has `electron` defaulted to electron_27
  # alpine builds signal-desktop using its default electron version, i.e. 27.0.2
  # verified working:
  # - electron-bin  (26)
  # - electron_27-bin (builds, haven't extensively tested the runtime)
  # the non-bin varieties *seem* to ship the wrong `electron.headers` property.
  # - maybe they can work if i manually DL and ship the corresponding headers
  electron' = electron_27-bin;

  buildNpmArch = if stdenv.buildPlatform.isAarch64 then "arm64" else "x64";
  hostNpmArch = if stdenv.hostPlatform.isAarch64 then "arm64" else "x64";
  crossNpmArchExt = if buildNpmArch == hostNpmArch then "" else "-${hostNpmArch}";
in
stdenv.mkDerivation rec {
  pname = "signal-desktop-from-src";
  inherit src version;

  patches = [
    # ./debug.patch
    # fix bug that signal launches in the background on wayland
    # - <https://github.com/signalapp/Signal-Desktop/issues/6368>
    # - without this, signal can be started with `signal-desktop & ; sleep 5; signal-desktop`
    #   - the second instance wakes the first one, and then exits
    ./show-on-launch.patch
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    fixup_yarn_lock
    git  # to calculate build date
    gnused
    makeShellWrapper
    buildNodejs
    python3
    wrapGAppsHook
    buildYarn
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
    nodejs'  # to patch in the runtime
    nspr
    nss
    pango
    # so that bettersqlite may link against sqlcipher (see patch)
    # but i don't know if it actually needs to. just copied this from alpine.
    # sqlcipher
  ];

  env.yarnOfflineCache = yarnOfflineCache;
  # env.SIGNAL_ENV = "production";
  # env.NODE_ENV = "production";
  # env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  dontWrapGApps = true;

  # NIX_DEBUG = 6;

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

    # XXX: Signal does not let clients connect if they're running a version that's > 90d old.
    # to calculate the build date, it uses SOURCE_DATE_EPOCH (if set), else `git log`.
    # nixpkgs sets SOURCE_DATE_EPOCH to 1980/01/01 by default, so unset it so Signal falls back to git date.
    # see: Signal-Desktop/ts/scripts/get-expire-time.ts
    export SOURCE_DATE_EPOCH=

    export HOME=$NIX_BUILD_TOP
    yarn config --offline set yarn-offline-mirror $yarnOfflineCache
    fixup_yarn_lock yarn.lock

    # prevent any attempt at downloading nodejs C headers
    # see: <https://www.electronjs.org/docs/latest/tutorial/using-native-node-modules>
    tar xzf ${electron'.headers}
    export npm_config_nodedir=$(pwd)/node_headers

    export npm_config_arch=${buildNpmArch}
    export npm_config_target_arch=${hostNpmArch}

    # optional flags:  --no-progress --non-interactive
    # yarn install creates the node_modules/ directory
    # --ignore-scripts tells yarn to not run the "install" or "postinstall" commands mentioned in dependencies' package.json
    #   since many of those require network access
    yarn install --offline --frozen-lockfile --ignore-scripts
    patchShebangs node_modules/
    patchShebangs --build --update node_modules/{bufferutil/node_modules/node-gyp-build/,node-gyp-build,utf-8-validate/node_modules/node-gyp-build}
    # patch these out to remove a runtime reference back to the build bash
    # (better, perhaps, would be for these build scripts to not be included in the asar...)
    sed -i 's:#!.*/bin/bash:#!/bin/sh:g' node_modules/@swc/helpers/scripts/gen.sh
    sed -i 's:#!.*/bin/bash:#!/bin/sh:g' node_modules/@swc/helpers/scripts/generator.sh
    substituteInPlace node_modules/dashdash/etc/dashdash.bash_completion.in --replace-fail '#!/bin/bash' '#!/bin/sh'

    set -x

    # provide necessecities which were skipped as part of --ignore-scripts
    cp ${ringrtcPrebuild} node_modules/@signalapp/ringrtc/scripts/prebuild.tar.gz
    pushd node_modules/@signalapp/ringrtc/
      tar -xzf ./scripts/prebuild.tar.gz
    popd
    cp ${sqlcipherTarball} node_modules/@signalapp/better-sqlite3/deps/sqlcipher.tar.gz
    pushd node_modules/@signalapp/better-sqlite3
      # node-gyp isn't consistently linked into better-sqlite's `node_modules` (maybe due to version mismatch with sinal-desktop's node-gyp?)
      PATH="$PATH:$(pwd)/../../.bin" yarn --offline build-release
    popd
    pushd node_modules/@signalapp/libsignal-client
      yarn node-gyp-build
    popd
    # there are more dependencies which had install/postinstall scripts, but it seems we can safely ignore them

    # run signal's own `postinstall`:
    yarn build:acknowledgments
    yarn patch-package
    # yarn electron:install-app-deps  # not necessary

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

    # allow building with different node version than what upstream package.json requests
    # (i still use the same major version)
    # echo 'ignore-engines true' > .yarnrc

    # yarn generate:
    yarn build-module-protobuf --offline --frozen-lockfile
    yarn build:esbuild --offline --frozen-lockfile
    yarn sass
    yarn get-expire-time
    yarn copy-components

    yarn build:esbuild:prod --offline --frozen-lockfile

    yarn build:release \
      --linux --${hostNpmArch} \
      -c.electronDist=${electron'}/libexec/electron \
      -c.electronVersion=${electron'.version} \
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
    # fixup the app.asar to use host nodejs
    ${buildPackages.asar}/bin/asar extract $out/lib/Signal/resources/app.asar unpacked
    rm $out/lib/Signal/resources/app.asar
    patchShebangs --host --update unpacked
    ${buildPackages.asar}/bin/asar pack unpacked $out/lib/Signal/resources/app.asar

    # XXX: add --ozone-platform-hint=auto to make it so that NIXOS_OZONE_WL isn't *needed*.
    # electron should auto-detect x11 v.s. wayland: launching with `NIXOS_OZONE_WL=1` is an optional way to force it when debugging.
    # xdg-utils: needed for ozone-platform-hint=auto to work
    # else `LaunchProcess: failed to execvp: xdg-settings`
    makeShellWrapper ${electron'}/bin/electron $out/bin/signal-desktop \
      "''${gappsWrapperArgs[@]}" \
      --add-flags $out/lib/Signal/resources/app.asar \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --add-flags --ozone-platform-hint=auto \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations}}" \
      --inherit-argv0
  '';

  passthru = {
    # inherit bettersqlitePatch signal-fts5-extension;
    updateScript = gitUpdater {
      # TODO: prevent update to betas
      rev-prefix = "v";
    };
    nodejs = nodejs';
    buildYarn = buildYarn;
    buildNodejs = buildNodejs;
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
