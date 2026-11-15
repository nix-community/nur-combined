{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  fetchzip,
  nodejs_24,
  electron_43-bin,
  prefetch-npm-deps,
  npm-lockfile-fix,
  buildVscode,
  writableTmpDirAsHomeHook,
  which,
  jq,
  pkg-config,
  krb5,
  node-gyp,
  writeShellScriptBin,
  cctools,
  xcbuild,
  ripgrep,
  runCommand,
  libsecret,
  libx11,
  libxkbfile,
  vscode-extensions,
  commandLineArgs ? "",
  useVSCodeRipgrep ? false,
  pname ? "vscodium",
  extraPatches ? [ ],
  description ? "Open source VS Code build (from source, VSCodium-branded)",
}:

# From-source VSCodium based on microsoft/vscode + VSCodium product branding.
# Build approach adapted from the experimental nixpkgs code-oss WIP
# (https://github.com/NixOS/nixpkgs/pull/445245), updated for vscode 1.143's
# TypeScript npm postinstall.
let
  inherit (stdenv) hostPlatform;
  inherit (hostPlatform.node) arch platform;
  commitInfo = lib.importJSON ./commit.json;
  nodejs = nodejs_24;
  electron = electron_43-bin;
  electron-dist-zip = electron_43-bin.src;
  # build/.npmrc targets Node 22; tree-sitter bindings need its headers (not Node 24).
  buildNodeHeadersVersion = "22.22.1";
  cache-dir =
    if hostPlatform.isDarwin then
      "$HOME/Library/Caches"
    else if hostPlatform.isLinux then
      "$HOME/.cache"
    else
      throw "Unsupported platform: ${platform}";

  # @vscode/ripgrep-universal postinstall looks for a pre-downloaded archive.
  # Point it at nixpkgs ripgrep instead of downloading.
  ripgrep-tgz = runCommand "ripgrep-${ripgrep.version}.tar.gz" { } ''
    tar -czf $out -C ${ripgrep}/bin rg
  '';

  # postinstall.ts calls ensureElectronTypes(), which otherwise fetches this.
  # Checksum matches build/checksums/electron.txt for vscode 1.143.1 (Electron 43.7.7).
  electron-d-ts = fetchurl {
    url = "https://github.com/electron/electron/releases/download/v43.7.7/electron.d.ts";
    hash = "sha256-14oR70WLaGcsNZV/AlI5ah+hnnOoyjuReOLnXNCQRT0=";
  };

  build-node-headers = fetchzip {
    url = "https://nodejs.org/dist/v${buildNodeHeadersVersion}/node-v${buildNodeHeadersVersion}-headers.tar.gz";
    hash = "sha256-v0jbsTneBNPe5mQFKt0QywXxgmhgZarW1hhutwlCcsQ=";
  };

  vscodium-build = stdenv.mkDerivation (finalAttrs: {
    pname = "${pname}-unwrapped";
    version = "1.143.17232";

    src = fetchFromGitHub {
      owner = "microsoft";
      repo = "vscode";
      # VSCodium 1.143.17232 tracks vscode 1.143.1.
      tag = "1.143.1";
      hash = "sha256-GuR+613RHZ876yC1e1glj0TC+4syMDG0SV7IVKY7S+4=";
    };

    patches = [
      ./patches/postinstall-nix.patch
      ./patches/date-nix.patch
      ./patches/gulpfile-reh-nodeversion.patch
      ./patches/skip-missing-copilot-sdk.patch
    ]
    ++ extraPatches;

    npmDeps = stdenvNoCC.mkDerivation {
      name = "vscodium-${finalAttrs.version}-npm-deps";
      inherit (finalAttrs) src patches;

      nativeBuildInputs = [
        prefetch-npm-deps
        npm-lockfile-fix
      ];

      buildPhase = ''
        # rspack (and some other) lockfiles omit resolved/integrity for peer deps.
        find . -name package-lock.json -exec npm-lockfile-fix {} \;

        mkdir -p "$out/locks"
        FORCE_EMPTY_CACHE=true find . -name package-lock.json -exec sh -c '
          echo "prefetch-npm-deps $1"
          prefetch-npm-deps "$1" "$out"
          cp --parents "$1" "$out/locks/"
        ' _ {} \;
        rm -f "$out/package-lock.json"
      '';

      outputHashMode = "recursive";
      outputHash = "sha256-miPmgWywubDqsEbz69MTGBrBz758Ibbq7QsoovS8nq4=";
    };

    buildInputs = [
      krb5
    ]
    ++ lib.optionals hostPlatform.isLinux [
      libsecret
      libx11
      libxkbfile
    ];

    nativeBuildInputs = [
      writableTmpDirAsHomeHook
      nodejs
      nodejs.python
      which
      jq
      pkg-config
      node-gyp
      (writeShellScriptBin "npm-install-script" ''
        source "$stdenv/setup"
        set -euo pipefail
        # Used by build/npm/postinstall.ts for each workspace package-lock.json.
        npm ci --ignore-scripts --legacy-peer-deps

        # keytar pulls in node-addon-api 4.x, which initializes a static enum
        # member with -1. Newer clang rejects that out-of-range enum conversion
        # in a constant expression ("in-class initializer for static data member
        # is not a constant expression"), breaking keytar's node-gyp build.
        # Use a value inside the enum's range that Node-API never reports.
        for napi_h in $(find node_modules -path '*/node-addon-api/napi.h'); do
          substituteInPlace "$napi_h" \
            --replace-quiet 'static const napi_typedarray_type unknown_array_type = static_cast<napi_typedarray_type>(-1);' \
                      'static constexpr napi_typedarray_type unknown_array_type = static_cast<napi_typedarray_type>(15);'
        done

        patchShebangs node_modules
        npm rebuild --legacy-peer-deps
        patchShebangs node_modules
      '')
    ]
    ++ lib.optionals hostPlatform.isDarwin [
      cctools.libtool
      xcbuild
    ];

    strictDeps = true;

    env = {
      BUILD_DATE = commitInfo.committer.date;
      BUILD_SOURCEVERSION = commitInfo.sha;
      VSCODE_FORCE_INSTALL = "1";
      VSCODE_QUALITY = "stable";
      npm_install_command = "npm-install-script";
      PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "true";
      ELECTRON_SKIP_BINARY_DOWNLOAD = "true";
      NODE_OPTIONS = "--max-old-space-size=8192";
    };

    postPatch = ''
      # VSCodium branding (subset of prepare_vscode.sh product.json edits).
      jq \
        --arg nameShort "VSCodium" \
        --arg nameLong "VSCodium" \
        --arg applicationName "codium" \
        --arg dataFolderName ".vscodium-server" \
        --arg linuxIconName "vscodium" \
        --arg urlProtocol "vscodium" \
        --arg quality "stable" \
        --argjson extensionsGallery '{"serviceUrl":"https://open-vsx.org/vscode/gallery","itemUrl":"https://open-vsx.org/vscode/item","latestUrlTemplate":"https://open-vsx.org/vscode/gallery/{publisher}/{name}/latest","controlUrl":"https://raw.githubusercontent.com/EclipseFdn/publish-extensions/refs/heads/master/extension-control/extensions.json"}' \
        '.nameShort=$nameShort
         | .nameLong=$nameLong
         | .applicationName=$applicationName
         | .dataFolderName=".vscodium"
         | .serverDataFolderName=$dataFolderName
         | .linuxIconName=$linuxIconName
         | .urlProtocol=$urlProtocol
         | .quality=$quality
         | .extensionsGallery=$extensionsGallery
         | .reportIssueUrl="https://github.com/VSCodium/vscodium/issues/new"
         | .licenseUrl="https://github.com/VSCodium/vscodium/blob/master/LICENSE"
         | .updateUrl=null
         | .backupUpdateUrl=null' \
        product.json > product.json.tmp
      mv product.json.tmp product.json
    '';

    buildPhase = ''
      runHook preBuild

      mkdir -p "$TMPDIR/cache"
      cp -a "$npmDeps/_cacache" "$TMPDIR/cache/"
      chmod -R 700 "$TMPDIR/cache"
      export npm_config_cache="$TMPDIR/cache"
      export npm_config_offline="true"
      export npm_config_progress="false"
      export npm_config_legacy_peer_deps="true"

      mkdir -p "${cache-dir}/node-gyp/${electron.version}"
      echo 11 > "${cache-dir}/node-gyp/${electron.version}/installVersion"
      ln -s "${electron.headers}/include" "${cache-dir}/node-gyp/${electron.version}/include"

      mkdir -p "${cache-dir}/node-gyp/${nodejs.version}"
      echo 11 > "${cache-dir}/node-gyp/${nodejs.version}/installVersion"
      ln -s "${nodejs}/include" "${cache-dir}/node-gyp/${nodejs.version}/include"

      # build/.npmrc targets Node ${buildNodeHeadersVersion} for tree-sitter native addons.
      mkdir -p "${cache-dir}/node-gyp/${buildNodeHeadersVersion}"
      echo 11 > "${cache-dir}/node-gyp/${buildNodeHeadersVersion}/installVersion"
      ln -s "${build-node-headers}/include" "${cache-dir}/node-gyp/${buildNodeHeadersVersion}/include"

      # remote/.npmrc targets 24.22.1; reuse nixpkgs nodejs 24.x headers.
      # Do not set npm_config_nodedir globally: build/ tree-sitter must use Node 22 headers.
      mkdir -p "${cache-dir}/node-gyp/24.22.1"
      echo 11 > "${cache-dir}/node-gyp/24.22.1/installVersion"
      ln -sfn "${nodejs}/include" "${cache-dir}/node-gyp/24.22.1/include"

      # Use lockfiles fixed by npm-lockfile-fix (peer resolved/integrity fields).
      if [ -d "$npmDeps/locks" ]; then
        cp -rT "$npmDeps/locks" .
      fi

      # Align .npmrc electron target with nixpkgs electron_43-bin.
      substituteInPlace .npmrc \
        --replace-fail 'target="43.7.7"' 'target="${electron.version}"'

      electronCacheDir="${cache-dir}/electron/$(printf 'https://github.com/electron/electron/releases/download/v${electron.version}' | sha256sum | cut -f1 -d' ')"
      mkdir -p "$electronCacheDir"
      ln -s ${electron-dist-zip} "$electronCacheDir/electron-v${electron.version}-${platform}-${arch}.zip"

      # Satisfy @vscode/ripgrep / ripgrep-universal download checks with nixpkgs rg.
      mkdir -p "$TMPDIR/vscode-ripgrep-cache-placeholder"
      ln -sf ${ripgrep-tgz} "$TMPDIR"/vscode-ripgrep-cache-*/ripgrep-*.tar.gz 2>/dev/null || true
      for d in "$TMPDIR"/vscode-ripgrep-cache-*; do
        [ -d "$d" ] || continue
        ln -sfn ${ripgrep-tgz} "$d/rg.tar.gz"
      done
      # Also expose rg on PATH for any direct lookups.
      export PATH="${ripgrep}/bin:$PATH"

      ln -s ${vscode-extensions.ms-vscode.js-debug-companion.vsix} ./ms-vscode.js-debug-companion.vsix
      ln -s ${vscode-extensions.ms-vscode.js-debug.vsix} ./ms-vscode.js-debug.vsix
      ln -s ${vscode-extensions.ms-vscode.vscode-js-profile-table.vsix} ./ms-vscode.vscode-js-profile-table.vsix

      jq \
        --arg js_debug_companion_vsix_sha "$(sha256sum ./ms-vscode.js-debug-companion.vsix | cut -d' ' -f1)" \
        --arg js_debug_vsix_sha "$(sha256sum ./ms-vscode.js-debug.vsix | cut -d' ' -f1)" \
        --arg vscode_js_profile_table_vsix_sha "$(sha256sum ./ms-vscode.vscode-js-profile-table.vsix | cut -d' ' -f1)" \
        '.builtInExtensions |=
          map(if .name == "ms-vscode.js-debug-companion" then del(.repo) | .vsix = "./\(.name).vsix" | .sha256 = $js_debug_companion_vsix_sha
            elif .name == "ms-vscode.js-debug" then del(.repo) | .vsix = "./\(.name).vsix" | .sha256 = $js_debug_vsix_sha
            elif .name == "ms-vscode.vscode-js-profile-table" then del(.repo) | .vsix = "./\(.name).vsix" | .sha256 = $vscode_js_profile_table_vsix_sha
            else . end)' product.json > product.json.tmp && mv product.json.tmp product.json

      # Skip electron artifact checksums when using nixpkgs' zip.
      if [ -f build/lib/electron.ts ]; then
        substituteInPlace build/lib/electron.ts \
          --replace-fail 'validateChecksum: true' 'validateChecksum: false' || true
      fi

      # Satisfy ensureElectronTypes() offline (checksum-verified against electron.txt).
      mkdir -p .build/typings
      cp ${electron-d-ts} .build/typings/electron.d.ts

      # Root deps first (ignore scripts), then install the bundled node-gyp, then
      # run vscode's multi-package postinstall which uses npm_install_command.
      npm ci --ignore-scripts
      patchShebangs node_modules || true

      if [ -f build/npm/gyp/package-lock.json ]; then
        (cd build/npm/gyp && npm ci --ignore-scripts && patchShebangs node_modules || true)
      fi

      # Point npm_config_node_gyp at nixpkgs node-gyp as a fallback.
      export npm_config_node_gyp="${lib.getExe node-gyp}"

      node build/npm/postinstall.ts

      patchShebangs node_modules build/node_modules || true

      if [ -f node_modules/@vscode/gulp-electron/src/download.js ]; then
        substituteInPlace node_modules/@vscode/gulp-electron/src/download.js \
          --replace-fail 'let downloadOpts = {' 'let downloadOpts = { unsafelyDisableChecksums: true,' || true
      fi

      node --run gulp -- vscode-${platform}-${arch}-min
    ''
    + lib.optionalString hostPlatform.isDarwin ''
      mv "../VSCode-${platform}-${arch}/VSCodium.app" $out \
        || mv "../VSCode-${platform}-${arch}/Code - OSS.app" $out
    ''
    + lib.optionalString hostPlatform.isLinux ''
      mv "../VSCode-${platform}-${arch}" $out
    ''
    + ''
      runHook postBuild
    '';

    # Avoid stdenv phases that assume a normal install layout.
    dontInstall = true;
  });
in
buildVscode {
  inherit
    commandLineArgs
    useVSCodeRipgrep
    pname
    ;

  inherit (vscodium-build) version;
  vscodeVersion = "1.143.1";

  executableName = "codium";
  # vscode's packaging step always writes the launcher as bin/code.
  sourceExecutableName = "code";
  longName = "VSCodium";
  shortName = "vscodium";
  libraryName = "vscode";
  iconName = "vscodium";

  src = vscodium-build;
  sourceRoot = "";

  tests = { };
  updateScript = null;

  meta = {
    inherit description;
    mainProgram = "codium";
    longDescription = ''
      VSCodium-branded build of Microsoft's MIT-licensed vscode sources, compiled
      in this repository instead of using the upstream binary release.
    '';
    homepage = "https://github.com/VSCodium/vscodium";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
