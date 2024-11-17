## runtime error (temporarily fixed for x64 only, ringrtc):
- ```
  Error: Cannot find module '../../build/linux/libringrtc-x64.node'
  Require stack:
  - /nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/ringrtc/dist/ringrtc/Native.js
  - /nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/ringrtc/dist/ringrtc/CallLinks.js
  - /nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/ringrtc/dist/ringrtc/Service.js
  - /nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/ringrtc/dist/index.js
  - /nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/migrations/89-call-history.js
  - /nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/migrations/index.js
  - /nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/app/main.js
  - /nix/store/nqp0wqs8xa2dw36yc6i1lyhnx0m39fsk-electron-unwrapped-27.0.0/libexec/electron/resources/default_app.asar/main.js
  -
      at node:internal/modules/cjs/loader:1084:15
      at Function._resolveFilename (node:electron/js2c/browser_init:2:116646)
      at node:internal/modules/cjs/loader:929:27
      at Function._load (node:electron/js2c/asar_bundle:2:13327)
      at Module.require (node:internal/modules/cjs/loader:1150:19)
      at require (node:internal/modules/cjs/helpers:121:18)
      at Object.<anonymous> (/nix/store/lmk7ify4gq5i23832cn4qriqy5cr7asb-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/ringrtc/dist/ringrtc/Native.js:33:19)
      at Module._compile (node:internal/modules/cjs/loader:1271:14)
      at Object..js (node:internal/modules/cjs/loader:1326:10)
      at Module.load (node:internal/modules/cjs/loader:1126:32)
  ```
- `ringrtc` doesn't exist anywhere inside the installed result -- but that _could_ be because of the asar, or it could be because it doesn't get installed
- package.json has a `"build"` key, which references ringrtc in the "singleArchFiles" subfield
  - "singleArchFiles": "node_modules/@signalapp/{libsignal-client/prebuilds/**,ringrtc/build/**}"
  - maybe this is getting overlooked because of the way i build?
- `ringrtc` exists in the build dir at `./source/node_modules/@signalapp/ringrtc/`
  - but no `libringrtc`
  - and notably, no `node_modules/@signalapp/ringrtc/build` -- which was mentioned in package.json.
  - so, i probably need to manually build that.
- nixpkgs `signal-desktop` includes this line, suggesting that the prebuilt distribution includes the referenced ringrtc file:
  - `patchelf --add-needed ${libpulseaudio}/lib/libpulse.so "$out/lib/${dir}/resources/app.asar.unpacked/node_modules/@signalapp/ringrtc/build/linux/libringrtc-x64.node"`

## runtime error (sqlite)
- ```
  Unhandled Promise Rejection: Error: Error: Could not locate the bindings file. Tried:
   → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/build/better_sqlite3.node
   → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/build/Debug/better_sqlite3.node
   → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/build/Release/better_sqlite3.node
   → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/out/Debug/better_sqlite3.node
   → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/Debug/better_sqlite3.node
   → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/out/Release/better_sqlite3.node
   → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/Release/better_sqlite3.node
   → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/build/default/better_sqlite3.node
   → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/compiled/18.15.0/linux/x64/better_sqlite3.node
   → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/addon-build/release/install-root/better_sqlite3.node
   → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/addon-build/debug/install-root/better_sqlite3.node
   → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/addon-build/default/install-root/better_sqlite3.node
   → /nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/lib/binding/node-v116-linux-x64/better_sqlite3.node
      at bindings (/nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/bindings/bindings.js:126:9)
      at new Database (/nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/lib/database.js:48:64)
      at openAndMigrateDatabase (/nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/Server.js:365:8)
      at openAndSetUpSQLCipher (/nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/Server.js:383:14)
      at Object.initialize (/nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/Server.js:419:16)
      at MessagePort.<anonymous> (/nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/mainWorker.js:84:35)
      at [nodejs.internal.kHybridDispatch] (node:internal/event_target:735:20)
      at exports.emitMessage (node:internal/per_context/messageport:23:28)
      at Worker.<anonymous> (/nix/store/0kq63cnarayn7cq8c35729j324p7qgi6-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/main.js:62:26)
      at Worker.emit (node:events:513:28)
      at MessagePort.<anonymous> (node:internal/worker:234:53)
      at [nodejs.internal.kHybridDispatch] (node:internal/event_target:735:20)
      at exports.emitMessage (node:internal/per_context/messageport:23:28)
  ```

## runtime hang:
- during boot, this message looks sus:
  - `{"level":50,"time":"2023-11-02T15:45:33.925Z","msg":"Preload error in [REDACTED]/preload.bundle.js:  Cannot read properties of undefined (reading 'PureComponent')"}`
- worth trying to build better-sqlite.
  - `make: *** No rule to make target '../deps/sqlcipher.tar.gz', needed by 'b857c92884e9598d609f6be182a2595df7a8e00f.intermediate'.  Stop.`
  - alpine patches it to use system sqlcipher.
  - nixpkgs has sqlcipher: should try the same thing

  - after shipping sqlcipher:
    ```
    In file included from ../src/better_sqlite3.cpp:4:
    ./src/better_sqlite3.lzz:14:10: fatal error: signal-tokenizer.h: No such file or directory
  - signal-tokenizer: <https://github.com/signalapp/Signal-FTS5-Extension>
    - allows full-text-search for sqlite CJK languages
    - i should just disable it, if possible?
      - somehow signal-desktop doesn't contain any tokenizer files, even though it's a rust binary?
      - text references to signal_tokenizer, though
      - oh: static linking (against (SHARED_INTERMEDIATE_DIR)/sqlite3/signal-tokenizer/>(rust_arch)-unknown-linux-gnu/libsignal_tokenizer.a)
    - signal's better-sqlite3 hardcodes a #include for signal-tokenizer.h; it's not toggleable
    - simply deleting source references to the tokenizer causes a runtime error:
      ```
      Unhandled Promise Rejection: Error: Error: /nix/store/hf4crvgi4rmm3cg0l1pc9pbvzq0y6kh0-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/better-sqlite3/build/Release/better_sqlite3.node: undefined symbol: _ZN2v812api_internal18GlobalizeReferenceEPNS_8internal7IsolateEPm
          at process.func [as dlopen] (node:electron/js2c/asar_bundle:2:1869)
          at Module._extensions..node (node:internal/modules/cjs/loader:1354:18)
          at Object.func [as .node] (node:electron/js2c/asar_bundle:2:2096)
          at Module.load (node:internal/modules/cjs/loader:1124:32)
          at Module._load (node:internal/modules/cjs/loader:965:12)
          at f._load (node:electron/js2c/asar_bundle:2:13377)
          at Module.require (node:internal/modules/cjs/loader:1148:19)
          at require (node:internal/modules/cjs/helpers:110:18)
          at bindings (/nix/store/hf4crvgi4rmm3cg0l1pc9pbvzq0y6kh0-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/bindings/bindings.js:112:48)
          at new Database (/nix/store/hf4crvgi4rmm3cg0l1pc9pbvzq0y6kh0-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/lib/database.js:48:64)
          at Worker.<anonymous> (/nix/store/hf4crvgi4rmm3cg0l1pc9pbvzq0y6kh0-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/main.js:62:26)
          at Worker.emit (node:events:513:28)
          at MessagePort.<anonymous> (node:internal/worker:234:53)
          at [nodejs.internal.kHybridDispatch] (node:internal/event_target:735:20)
          at exports.emitMessage (node:internal/per_context/messageport:23:28)
      ```
      - possibly that's a broken reference to v8::Isolate? but that's used by ordinary better-sqlite
      - `v8::api_internal::GlobalizeReference(v8::internal::Isolate*, unsigned long*)`  - as per c++filt
      - seems a problem whenever multiple nodejs versions are mixed?
        - <https://github.com/refi64/zypak/issues/20>
      - error message is for better-sqlite, but maybe it's actually because of the rtc stuff (which used a different nodejs)?
      - happens for electron 25, 26 and 27
      - pre-packaged signal-desktop has better-sqlite which doesn't link against anything special like v8, and includes the symbol:
        - `_ZN2v812api_internal18GlobalizeReferenceEPNS_8internal7IsolateEm`
        - notice: IsolateEm instead of IsolatedEPm
        - `v8::api_internal::GlobalizeReference(v8::internal::Isolate*, unsigned long)`
        - i.e. that `unsized long` isn't a pointer!
        - GlobalizeReference doesn't occur in better-sqlite source
      - v8 is a part of nodejs, as is GlobalizeReference.
        - could this be related to that "unable to figure out ABI" thing?
      - somehow related to node-gyp:
        .node-gyp/18.18.2/include/node/v8-persistent-handle.h
          36:V8_EXPORT internal::Address* GlobalizeReference(internal::Isolate* isolate,
          37-                                                internal::Address* handle);
        nixpkgs' nodejs is indeed 18.18.2. upstream nodejs is 21.1.0.
        this header matches what nodejs 18.18.2 provides!
      - maybe related to electron.headers? probably not though. nix path-info on electron doesn't show any trace of node
      - in fact, nix path-info on signal-desktop-from-src refers to nodejs, which contains in `bin/nodejs` the use of this symbol:
        - `_ZN2v812api_internal18GlobalizeReferenceEPNS_8internal7IsolateEPm`
        - so.... THERE'S NO REASON FOR ME TO SEE THIS ERROR!!
      - in the build dir, this file DOES contain GlobalizeReference, of the right signature: `./source/release/linux-unpacked/signal-desktop`
        - same file as in the pre-built signal-desktop
        - this is the one which segfaults on launch though.
          - because it needs suid bit. invoke with `--no-sandbox` instead!
          - but then we get the same identical undefined symbol error as above!
          - do i have it inverted: nodejs runs signal-desktop, not that electron runs signal-desktop?
      - note in the build dir, a PREBUILT: source/release/linux-unpacked/resources/app.asar.unpacked/node_modules/@signalapp/libsignal-client/prebuilds/linux-x64/node.napi.node
        - is this the Native API for node?? wtf is signal doing?
          - indeed they ship binaries on npm: <https://www.npmjs.com/package/@signalapp/libsignal-client/v/0.33.0?activeTab=code>
        - i think i need to just blindly copy the Alpine build routine, and then it'll work. they're clearly doing all their involved stuff for SOME reason

## after linking in libsignal_tokenizer and libv8 and libicu:
- <https://github.com/WiseLibs/better-sqlite3/issues/187#issuecomment-587085448>
- ```
  Unhandled Promise Rejection: Error: Error: Module did not self-register: '/nix/store/nbf47bl99qfw01dmrf9q0sk5xzs4sq6r-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/better-sqlite3/build/Release/better_sqlite3.node'.
      at process.func [as dlopen] (node:electron/js2c/asar_bundle:2:1869)
      at Module._extensions..node (node:internal/modules/cjs/loader:1354:18)
      at Object.func [as .node] (node:electron/js2c/asar_bundle:2:2096)
      at Module.load (node:internal/modules/cjs/loader:1124:32)
      at Module._load (node:internal/modules/cjs/loader:965:12)
      at f._load (node:electron/js2c/asar_bundle:2:13377)
      at Module.require (node:internal/modules/cjs/loader:1148:19)
      at require (node:internal/modules/cjs/helpers:110:18)
      at bindings (/nix/store/nbf47bl99qfw01dmrf9q0sk5xzs4sq6r-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/bindings/bindings.js:112:48)
      at new Database (/nix/store/nbf47bl99qfw01dmrf9q0sk5xzs4sq6r-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/node_modules/@signalapp/better-sqlite3/lib/database.js:48:64)
      at Worker.<anonymous> (/nix/store/nbf47bl99qfw01dmrf9q0sk5xzs4sq6r-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar/ts/sql/main.js:62:26)
      at Worker.emit (node:events:513:28)
      at MessagePort.<anonymous> (node:internal/worker:234:53)
      at [nodejs.internal.kHybridDispatch] (node:internal/event_target:735:20)
      at exports.emitMessage (node:internal/per_context/messageport:23:28)
  ```
- better-sqlite "guide" for Electron users: <https://github.com/WiseLibs/better-sqlite3/issues/126>

## ABI differences (?)
- "Error: The module '/nix/store/y1xy2dli178cby734lshmm0g5vnzwir2-signal-desktop-from-src-6.36.0/lib/Signal/resources/app.asar.unpacked/node_modules/@signalapp/better-sqlite3/build/Release/better_sqlite3.node' was compiled against a different Node.js version using NODE_MODULE_VERSION 108. This version of Node.js requires NODE_MODULE_VERSION 116"
- signal-desktop package.json references as the "engine": node 18.15.0
- nixpkgs ships nodejs 18.18.2
- electron-rebuild is somehow used for stuff like this?
- version list is here: <https://github.com/nodejs/node/blob/HEAD/doc/abi_version_registry.json>
- 116 = electron 25
- 108 = node 18.0.0
- so, my node modules were built for node 18.x, but i'm trying to run them with electron.
- oh! this is why Alpine compiles with: --nodedir=/usr/include/electron/node_headers
- yup, running under electron 27 causes this number to go to 118 (as expected)
  - electron.headers is nodejs 18.15.0 and still specifies `#define NODE_MODULE_VERSION 108` (so, no good!)
- this error message comes from the electron binary, itself
  - version encoded into electron binary with `"node_module_version": 116`
  - encoded into node_modules/@signalapp/better-sqlite3/build/config.gypi
    - when correct: built with `"nodedir": "/home/colin/.electron-gyp/26.3.0"`
    - when correct: doesn't have ldd dep against sqlcipher or libcrypto or libz or libdl
    - IT'S DEFINITELY THE FUCKING BETTER-SQLITE WHICH IS GIVING ME PROBLEMS


## node-gyp trying to download stuff, try:
```nix
# `node-gyp rebuild` is invoked somewhere, and without this it tries to download node headers from electronjs.org
# mkdir -p "$HOME/.node-gyp/${electron.version}"
# echo 9 > "$HOME/.node-gyp/${electron.version}/installVersion"
# ln -sfv "$(pwd)/node_headers/include" "$HOME/.node-gyp/${electron.version}"

# mkdir -p "$HOME/.node-gyp/${nodejs'.version}"
# echo 9 > "$HOME/.node-gyp/${nodejs'.version}/installVersion"
# ln -sfv "$(pwd)/include" "$HOME/.node-gyp/${nodejs'.version}"
# export npm_config_nodedir=${nodejs'}
```


## client thinks it's outdated
"This version of Signal Desktop has expired. Please upgrade to the latest version to continue messaging.
Click to go to signal.org/download"
- and yes, i can't message (it repeats the first line when i try to send a message)
- message is identified by `icu:expiredWarning` and `icu:upgrade`
- instantiated by `DialogExpiredBuild` (ts/components/DialogExpiredBuild.tsx)
  - called by `renderExpiredBuildDialog` (ts/state/smart/LeftPane.tsx)
    - conditionally called by `LeftPane` if `hasExpiredDialog` (ts/components/LeftPane.tsx)
      - `hasExpiredDialog` is set to `hasExpired(state)` (ts/state/smart/LeftPane.tsx)
        - `hasExpired` defined in ts/state/selectors/expiration.ts

```ts
export const hasExpired = createSelector(
  getExpirationTimestamp,
  getAutoDownloadUpdate,
  (_: StateType, { now = Date.now() }: HasExpiredOptionsType = {}) => now,
  (buildExpiration: number, autoDownloadUpdate: boolean, now: number) => {
    if (getEnvironment() !== Environment.Production && buildExpiration === 0) {
      return false;
    }

    if (isInPast(buildExpiration)) {
      return true;
    }

    const safeExpirationMs = autoDownloadUpdate
      ? NINETY_ONE_DAYS
      : THIRTY_ONE_DAYS;

    const buildExpirationDuration = buildExpiration - now;
    const tooFarIntoFuture = buildExpirationDuration > safeExpirationMs;

    if (tooFarIntoFuture) {
      log.error(
        'Build expiration is set too far into the future',
        buildExpiration
      );
    }

    return tooFarIntoFuture || isInPast(buildExpiration);
  }
);
```

- log: `~/.config/Signal/logs/app.log`:
  - has `{"level":30,"time":"2023-11-17T01:26:29.259Z","msg":"Build expires (local): 1980-03-31T00:00:00.000Z"}`
  - suggests that `buildExpiration` is 0.
- quick fix is to make it so this check fails `getEnvironment() !== Environment.Production`
  - i.e. change the Environment to Development. dunno the side effects.
- in `app/main.ts`: `buildExpiration: config.get<number>('buildExpiration')`
- in `config/default.json`:
  - "updatesEnabled": false,
  - "ciMode": false,
  - "forcePreloadBundle": false,
  - "openDevTools": false,
  - "buildCreation": 0,
  - "buildExpiration": 0,
- `ts/scripts/get-expire-time.ts`
  - seems to calculate `buildCreation` (from `git` log) and `buildExpiration`
  - it writes this to `config/local-production.json`
- part of `generate` (package.json) is to call `get-expire-time`
  - i already run that during build
- alpine does a production build:
```sh
# build front
NODE_ENV=production \
SIGNAL_ENV=production \
NODE_OPTIONS=--openssl-legacy-provider \
yarn build:dev

# purge non-production deps
yarn install --ignore-scripts --frozen-lockfile --production
```

- these values made it into the asar:
  - `{"buildCreation":315532800000,"buildExpiration":323308800000}`
    - N.B. `315532800000` is 10 years in units of millisecnds
    - i.e. the buildCreation is 1980/01/01!
- in the log:
  - `{"level":30,"time":"2023-11-17T01:26:27.871Z","msg":"environment: production"}`
  - `{"level":40,"time":"2023-11-17T01:26:28.264Z","msg":"Remote Config: sever clock skew detected. Server time 1700184388000000, local time 1700184387985"}`
- some weird interplay between `local` and `production` env types?
