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
{ lib
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
, stdenv
, yarn
}:
let
  # package.json locks electron to 25.8.4
  # element-desktop uses electron_26
  # nixpkgs has `electron` defaulted to electron_27
  # alpine builds signal-desktop using its default electron version, i.e. 27.0.2
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

    mkdir -p "$HOME/.node-gyp/${nodejs.version}"
    echo 9 > "$HOME/.node-gyp/${nodejs.version}/installVersion"
    ln -sfv "${nodejs}/include" "$HOME/.node-gyp/${nodejs.version}"
    export npm_config_nodedir=${nodejs}

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
