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
# runtime hang:
# - during boot, this message looks sus:
#   - `{"level":50,"time":"2023-11-02T15:45:33.925Z","msg":"Preload error in [REDACTED]/preload.bundle.js:  Cannot read properties of undefined (reading 'PureComponent')"}`
# - worth trying to build better-sqlite.
#   - `make: *** No rule to make target '../deps/sqlcipher.tar.gz', needed by 'b857c92884e9598d609f6be182a2595df7a8e00f.intermediate'.  Stop.`
#   - alpine patches it to use system sqlcipher.
#   - nixpkgs has sqlcipher: should try the same thing
#
#   - after shipping sqlcipher:
#     ```
#     In file included from ../src/better_sqlite3.cpp:4:
#     ./src/better_sqlite3.lzz:14:10: fatal error: signal-tokenizer.h: No such file or directory
#   - signal-tokenizer: <https://github.com/signalapp/Signal-FTS5-Extension>
#     - allows full-text-search for sqlite CJK languages
#     - i should just disable it, if possible?
#       - somehow signal-desktop doesn't contain any tokenizer files, even though it's a rust binary?
#       - text references to signal_tokenizer, though
#       - oh: static linking (against (SHARED_INTERMEDIATE_DIR)/sqlite3/signal-tokenizer/>(rust_arch)-unknown-linux-gnu/libsignal_tokenizer.a)
#     - signal's better-sqlite3 hardcodes a #include for signal-tokenizer.h; it's not toggleable
#     - simply deleting source references to the tokenizer causes a runtime error:
#       ```
#       Unhandled Promise Rejection: Error: Error: /nix/store/hf4crvgi4rmm3cg0l1pc9pbvzq0y6kh0-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/better-sqlite3/build/Release/better_sqlite3.node: undefined symbol: _ZN2v812api_internal18GlobalizeReferenceEPNS_8internal7IsolateEPm
#           at process.func [as dlopen] (node:electron/js2c/asar_bundle:2:1869)
#           at Module._extensions..node (node:internal/modules/cjs/loader:1354:18)
#           at Object.func [as .node] (node:electron/js2c/asar_bundle:2:2096)
#           at Module.load (node:internal/modules/cjs/loader:1124:32)
#           at Module._load (node:internal/modules/cjs/loader:965:12)
#           at f._load (node:electron/js2c/asar_bundle:2:13377)
#           at Module.require (node:internal/modules/cjs/loader:1148:19)
#           at require (node:internal/modules/cjs/helpers:110:18)
#           at bindings (/nix/store/hf4crvgi4rmm3cg0l1pc9pbvzq0y6kh0-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/bindings/bindings.js:112:48)
#           at new Database (/nix/store/hf4crvgi4rmm3cg0l1pc9pbvzq0y6kh0-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/lib/database.js:48:64)
#           at Worker.<anonymous> (/nix/store/hf4crvgi4rmm3cg0l1pc9pbvzq0y6kh0-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/main.js:62:26)
#           at Worker.emit (node:events:513:28)
#           at MessagePort.<anonymous> (node:internal/worker:234:53)
#           at [nodejs.internal.kHybridDispatch] (node:internal/event_target:735:20)
#           at exports.emitMessage (node:internal/per_context/messageport:23:28)
#       ```
#       - possibly that's a broken reference to v8::Isolate? but that's used by ordinary better-sqlite
#       - `v8::api_internal::GlobalizeReference(v8::internal::Isolate*, unsigned long*)`  - as per c++filt
#       - seems a problem whenever multiple nodejs versions are mixed?
#         - <https://github.com/refi64/zypak/issues/20>
#       - error message is for better-sqlite, but maybe it's actually because of the rtc stuff (which used a different nodejs)?
#       - happens for electron 25, 26 and 27
#       - pre-packaged signal-desktop has better-sqlite which doesn't link against anything special like v8, and includes the symbol:
#         - `_ZN2v812api_internal18GlobalizeReferenceEPNS_8internal7IsolateEm`
#         - notice: IsolateEm instead of IsolatedEPm
#         - `v8::api_internal::GlobalizeReference(v8::internal::Isolate*, unsigned long)`
#         - i.e. that `unsized long` isn't a pointer!
#         - GlobalizeReference doesn't occur in better-sqlite source
#       - v8 is a part of nodejs, as is GlobalizeReference.
#         - could this be related to that "unable to figure out ABI" thing?
#       - somehow related to node-gyp:
#         .node-gyp/18.18.2/include/node/v8-persistent-handle.h
#           36:V8_EXPORT internal::Address* GlobalizeReference(internal::Isolate* isolate,
#           37-                                                internal::Address* handle);
#         nixpkgs' nodejs is indeed 18.18.2. upstream nodejs is 21.1.0.
#         this header matches what nodejs 18.18.2 provides!
#       - maybe related to electron.headers? probably not though. nix path-info on electron doesn't show any trace of node
#       - in fact, nix path-info on signal-desktop-from-src refers to nodejs, which contains in `bin/nodejs` the use of this symbol:
#         - `_ZN2v812api_internal18GlobalizeReferenceEPNS_8internal7IsolateEPm`
#         - so.... THERE'S NO REASON FOR ME TO SEE THIS ERROR!!
#       - in the build dir, this file DOES contain GlobalizeReference, of the right signature: `./source/release/linux-unpacked/signal-desktop`
#         - same file as in the pre-built signal-desktop
#         - this is the one which segfaults on launch though.
#           - because it needs suid bit. invoke with `--no-sandbox` instead!
#           - but then we get the same identical undefined symbol error as above!
#           - do i have it inverted: nodejs runs signal-desktop, not that electron runs signal-desktop?
#       - note in the build dir, a PREBUILT: source/release/linux-unpacked/resources/app.asar.unpacked/node_modules/@signalapp/libsignal-client/prebuilds/linux-x64/node.napi.node
#         - is this the Native API for node?? wtf is signal doing?
#           - indeed they ship binaries on npm: <https://www.npmjs.com/package/@signalapp/libsignal-client/v/0.33.0?activeTab=code>
#         - i think i need to just blindly copy the Alpine build routine, and then it'll work. they're clearly doing all their involved stuff for SOME reason
#
# after linking in libsignal_tokenizer and libv8 and libicu:
# - <https://github.com/WiseLibs/better-sqlite3/issues/187#issuecomment-587085448>
# - ```
#   Unhandled Promise Rejection: Error: Error: Module did not self-register: '/nix/store/nbf47bl99qfw01dmrf9q0sk5xzs4sq6r-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/better-sqlite3/build/Release/better_sqlite3.node'.
#       at process.func [as dlopen] (node:electron/js2c/asar_bundle:2:1869)
#       at Module._extensions..node (node:internal/modules/cjs/loader:1354:18)
#       at Object.func [as .node] (node:electron/js2c/asar_bundle:2:2096)
#       at Module.load (node:internal/modules/cjs/loader:1124:32)
#       at Module._load (node:internal/modules/cjs/loader:965:12)
#       at f._load (node:electron/js2c/asar_bundle:2:13377)
#       at Module.require (node:internal/modules/cjs/loader:1148:19)
#       at require (node:internal/modules/cjs/helpers:110:18)
#       at bindings (/nix/store/nbf47bl99qfw01dmrf9q0sk5xzs4sq6r-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/bindings/bindings.js:112:48)
#       at new Database (/nix/store/nbf47bl99qfw01dmrf9q0sk5xzs4sq6r-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/lib/database.js:48:64)
#       at Worker.<anonymous> (/nix/store/nbf47bl99qfw01dmrf9q0sk5xzs4sq6r-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/main.js:62:26)
#       at Worker.emit (node:events:513:28)
#       at MessagePort.<anonymous> (node:internal/worker:234:53)
#       at [nodejs.internal.kHybridDispatch] (node:internal/event_target:735:20)
#       at exports.emitMessage (node:internal/per_context/messageport:23:28)
#   ```
# - better-sqlite "guide" for Electron users: <https://github.com/WiseLibs/better-sqlite3/issues/126>
#
# ABI differences (?)
# - "Error: The module '/nix/store/y1xy2dli178cby734lshmm0g5vnzwir2-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/better-sqlite3/build/Release/better_sqlite3.node' was compiled against a different Node.js version using NODE_MODULE_VERSION 108. This version of Node.js requires NODE_MODULE_VERSION 116"
# - signal-desktop package.json references as the "engine": node 18.15.0
# - nixpkgs ships nodejs 18.18.2
# - electron-rebuild is somehow used for stuff like this?
# - version list is here: <https://github.com/nodejs/node/blob/HEAD/doc/abi_version_registry.json>
# - 116 = electron 25
# - 108 = node 18.0.0
# - so, my node modules were built for node 18.x, but i'm trying to run them with electron.
# - oh! this is why Alpine compiles with: --nodedir=/usr/include/electron/node_headers
# - yup, running under electron 27 causes this number to go to 118 (as expected)
#  - electron.headers is nodejs 18.15.0 and still specifies `#define NODE_MODULE_VERSION 108` (so, no good!)
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
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, autoPatchelfHook
, buildPackages
, callPackage
, cups
, electron_25
, electron_25-bin
# , electron_26
, electron
, electron-bin
, fetchFromGitHub
# , fetchYarnDeps
, flac
, fixup_yarn_lock
, gdk-pixbuf
, gtk3
, icu
, libpulseaudio
, libwebp
, libxslt
, makeWrapper
, mesa
, nodejs  # version 18
# , nodejs_latest
, nspr
, nss
, pango
, python3
, removeReferencesTo
, signal-desktop
, sqlite
, sqlcipher
, srcOnly
, stdenv
, substituteAll
, wrapGAppsHook
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
  # electron = electron_25;
  # electron = electron_25-bin;
  electron = electron-bin;
  # nodejs = nodejs_latest;
  nodeSources = srcOnly nodejs;
  bettersqlitePatch = substituteAll {
    # this patch does more than just use the system sqlcipher.
    # it also tells bettersqlite to link against its needed runtime dependencies,
    # since there's a few statically linked things which aren't called out.
    # it also tells bettersqlite not to download sqlcipher when we `npm rebuild`
    src = ./bettersqlite-use-system-sqlcipher.patch;
    inherit sqlcipher;
    inherit (nodejs) libv8;
    signal_fts5_extension = signal-fts5-extension;
  };
  signal-fts5-extension = callPackage ./fts5-extension { };
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

  patches = [
    ./debug.patch
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    fixup_yarn_lock
    makeWrapper
    nodejs  # possibly i could instead use nodejs-slim (npm-less nodejs)
    python3
    removeReferencesTo
    wrapGAppsHook
    yarn
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cups
    electron
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
    sqlcipher
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

    # see: <https://www.electronjs.org/docs/latest/tutorial/using-native-node-modules>
    # N.B. nixpkgs `electron.headers` ships ordinary nodejs headers; but `electron-bin.headers` ships the electron nodejs headers proper.
    # hence, this only works with the -bin variants of electron
    # folder structure is:
    # ./node_headers/include/node/*.h
    tar xzf ${electron.headers}
    export npm_config_nodedir=$(pwd)/node_headers
    export npm_config_target=${electron.version}
    export npm_config_runtime=electron
    export npm_config_arch=x64
    export npm_config_target_arch=x64


    # `node-gyp rebuild` is invoked somewhere, and without this it tries to download node headers from electronjs.org
    # mkdir -p "$HOME/.node-gyp/${electron.version}"
    # echo 9 > "$HOME/.node-gyp/${electron.version}/installVersion"
    # ln -sfv "$(pwd)/node_headers/include" "$HOME/.node-gyp/${electron.version}"

    # allow building with different node version than what upstream package.json requests
    # (i still use the same major version)
    echo 'ignore-engines true' > .yarnrc

    # build the sqlite bindings ELF
    pushd node_modules/@signalapp/better-sqlite3
    patch -p1 < ${bettersqlitePatch}

    # npm run build-release --offline
    # npm run build-release --offline --nodedir="${nodeSources}"

    # find build -type f -exec \
    #   remove-references-to \
    #   -t "${nodeSources}" {} \;

    popd

    npm rebuild @signalapp/better-sqlite3  --offline
    # npm rebuild @signalapp/better-sqlite3  --offline --nodedir="${nodeSources}" --build-from-source
    # patchelf --add-needed ${icu}/lib/libicutu.so node_modules/@signalapp/better-sqlite3/build/Release/better_sqlite3.node

    # provide the sqlite bindings ELF. TODO: build this from source
    # cp -R ${signal-desktop}/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/better-sqlite3/build \
    #   node_modules/@signalapp/better-sqlite3/

    # provide the ringrtc (webrtc) dependency. TODO: build this from source
    cp -R ${signal-desktop}/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/ringrtc/build \
      node_modules/@signalapp/ringrtc/

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

    # npm rebuild \
    #   @signalapp/better-sqlite3 \
    #   sharp spellchecker websocket \
    #   utf-8-validate bufferutil fs-xattr \
    #   --offline --nodedir="${nodeSources}" --build-from-source

    runHook postBuild
  '';

  # preInstall = ''
  #   # Build the sqlite3 package.
  #   npm_config_nodedir="${nodeSources}" npm_config_node_gyp="${buildPackages.nodejs}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js" npm rebuild --verbose --sqlite=${sqlite.dev} @signalapp/better-sqlite3
  # '';

  installPhase = ''
    runHook preInstall

    # directory structure follows the original `signal-desktop` nix package
    mkdir -p $out/lib/Signal
    cp -R release/linux-unpacked/* $out/lib/Signal
    # cp -R release/linux-unpacked/resources $out/lib/Signal/resources
    # cp -R release/linux-unpacked/locales $out/lib/Signal/locales

    mkdir $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/signal-desktop \
      --add-flags $out/lib/Signal/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --inherit-argv0
    # cp release/linux-unpacked/signal-desktop $out/bin
    # wrapProgram $out/bin/signal-desktop --add-flags --no-sandbox
    # ln -s $out/lib/Signal/signal-desktop $out/bin/signal-desktop

    runHook postInstall
  '';

  # preFixup = ''
  #   # the better-sqlite prebuilt by Signal has an implicit dep on libstdc++.so
  #   patchelf --add-needed ${lib.getLib stdenv.cc.cc}/lib/libstdc++.so "$out/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/better-sqlite3/build/Release/better_sqlite3.node"
  # '';

  # icu provides a number of .so's: libicuuc.so, libicutu.so, libici18n.so.
  # unsure which one better_sqlite specifically requires, but libicutu seems to link in every icu lib.
  preFixup = ''
    patchelf --add-needed ${icu}/lib/libicutu.so "$out/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/better-sqlite3/build/Release/better_sqlite3.node"
    # patchelf --add-needed ${lib.getLib stdenv.cc.cc}/lib/libstdc++.so "$out/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/better-sqlite3/build/Release/better_sqlite3.node"
  '';

  passthru = {
    inherit bettersqlitePatch signal-fts5-extension;
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
