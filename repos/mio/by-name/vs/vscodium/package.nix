{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  fetchzip,
  git,
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
  # VSCodium release that our version tracks (used for branding assets).
  vscodiumTag = "1.143.17232";
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

  # Upstream VSCodium repository at the release we track: the src/stable source
  # overlay (branded icons, resources and vscode source replacements), the patch
  # set, product.json additions and the welcome-page announcements.
  vscodiumSrc = fetchFromGitHub {
    owner = "VSCodium";
    repo = "vscodium";
    tag = vscodiumTag;
    hash = "sha256-4zKukdMZewlsQqEGXhI5goAv9vo5WMwEsVm18hFzzUs=";
  };

  # prepare_vscode.sh as a Nix string: lay VSCodium's source overlay over the
  # vscode tree, remove what it deletes, then apply its patch set with the
  # branding placeholders filled in. Both the npm dependency prefetch and the
  # build apply it, because the patches swap packages for VSCodium's forks
  # (@vscodium/policy-watcher, ...), which changes the lockfiles.
  vscodium-prepare = ''
    cp -R ${vscodiumSrc}/src/stable/. .
    cp ${vscodiumSrc}/LICENSE LICENSE.txt

    for actions in ${vscodiumSrc}/patches/*.json; do
      [ -e "$actions" ] || continue
      while IFS= read -r removal; do
        if [ -e "$removal" ]; then
          rm -rf -- "$removal"
        else
          echo "prePatch: '$removal' is already missing" >&2
          exit 1
        fi
      done < <(jq -r '.[] | select(.action == "remove") | .paths[]' "$actions")
    done

    for upstream_patch in ${vscodiumSrc}/patches/*.patch ${vscodiumSrc}/patches/${
      if hostPlatform.isDarwin then "osx" else "linux"
    }/*.patch; do
      [ -e "$upstream_patch" ] || continue
      expanded_patch=$(mktemp)
      sed -E \
        -e 's|!!APP_NAME!!|VSCodium|g' \
        -e 's|!!APP_NAME_LC!!|vscodium|g' \
        -e 's|!!ASSETS_REPOSITORY!!|VSCodium/vscodium|g' \
        -e 's|!!BINARY_NAME!!|codium|g' \
        -e 's|!!GH_REPO_PATH!!|VSCodium/vscodium|g' \
        -e 's|!!GLOBAL_DIRNAME!!|vscodium|g' \
        -e 's|!!ORG_NAME!!|VSCodium|g' \
        -e 's|!!RELEASE_VERSION!!|${vscodiumTag}|g' \
        -e 's|!!TUNNEL_APP_NAME!!|codium-tunnel|g' \
        "$upstream_patch" > "$expanded_patch"
      git apply --ignore-whitespace "$expanded_patch"
      rm -f "$expanded_patch"
    done
  '';

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
    version = vscodiumTag;
    # `reh` holds the remote server images; the app bundle stays in `out`.
    outputs = [
      "out"
      "reh"
    ];

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
      prePatch = vscodium-prepare;

      nativeBuildInputs = [
        prefetch-npm-deps
        npm-lockfile-fix
        git
        jq
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
      outputHash = "sha256-CoJ6/T0ZgVJePMRovOI6DcaPZN+mNVBWKrznag5ByFY=";
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
      git
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

        # The root workspace's own preinstall/postinstall are driven by the build
        # itself (postinstall.ts skips the root dir), and npm rebuild would run
        # them here, recursing into the per-directory installs, so hide them for
        # the rebuild. Some dependencies also download binaries at install time,
        # which cannot work in the sandbox.
        root_pkg=0
        if [ -f build/npm/postinstall.ts ] && [ -f package.json ]; then
          cp package.json package.json.nix-orig
          jq 'del(.scripts.preinstall, .scripts.postinstall)' package.json.nix-orig > package.json
          root_pkg=1
        fi
        for pkg in foundry-local-sdk @vscode/ripgrep @vscode/ripgrep-universal @vscode/deviceid; do
          for pj in $(find node_modules -maxdepth 5 -path "*/$pkg/package.json"); do
            jq 'del(.scripts.preinstall, .scripts.install, .scripts.postinstall)' "$pj" > "$pj.nix-tmp"
            mv "$pj.nix-tmp" "$pj"
          done
        done

        # The macOS policy watcher sends `&updatedPolicies[0]` even when no
        # managed preferences exist, which leaves the vector empty (NotSet
        # policies are never collected). Taking the address of element 0 of an
        # empty vector is undefined behaviour, and libc++'s hardening turns it
        # into a trap, so the app died at startup in PolicyWatcher::Execute.
        # (VSCodium replaces this package with @vscodium/policy-watcher, hence
        # the loose path match.)
        for pw_cc in $(find node_modules -path '*/policy-watcher/src/macos/PolicyWatcher.cc'); do
          if grep -q '&updatedPolicies\[0\]' "$pw_cc"; then
            substituteInPlace "$pw_cc" \
              --replace-fail 'progress.Send(&updatedPolicies[0], updatedPolicies.size());' \
                             'progress.Send(updatedPolicies.data(), updatedPolicies.size());'
          fi
        done

        npm rebuild --legacy-peer-deps
        patchShebangs node_modules

        if [ "$root_pkg" = 1 ]; then
          mv package.json.nix-orig package.json
        fi
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
      VSCODE_PUBLISH_COUNTER = "1";
      VSCODE_QUALITY = "stable";
      npm_install_command = "npm-install-script";
      PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "true";
      ELECTRON_SKIP_BINARY_DOWNLOAD = "true";
      NODE_OPTIONS = "--max-old-space-size=8192";
    };

    # Applied before `patches`, so our nix-specific adaptations land on top of
    # the branded tree.
    prePatch = vscodium-prepare;

    postPatch = ''
      # VSCodium branding: the product.json keys prepare_vscode.sh sets for a
      # stable build. darwinBundleIdentifier is what macOS keys the app identity
      # on (preferences domain, LaunchServices, policy watcher), and the server
      # and tunnel names decide the binaries used for remote sessions.
      jq \
        --arg nameShort "VSCodium" \
        --arg nameLong "VSCodium" \
        --arg applicationName "codium" \
        --arg darwinBundleIdentifier "com.vscodium" \
        --arg serverApplicationName "codium-server" \
        --arg tunnelApplicationName "codium-tunnel" \
        --arg dataFolderName ".vscodium-server" \
        --arg linuxIconName "vscodium" \
        --arg urlProtocol "vscodium" \
        --arg quality "stable" \
        --argjson linkProtectionTrustedDomains '["https://open-vsx.org"]' \
        --argjson tunnelApplicationConfig '{}' \
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
         | .darwinBundleIdentifier=$darwinBundleIdentifier
         | .serverApplicationName=$serverApplicationName
         | .tunnelApplicationName=$tunnelApplicationName
         | .tunnelApplicationConfig=$tunnelApplicationConfig
         | .linkProtectionTrustedDomains=$linkProtectionTrustedDomains
         | .reportIssueUrl="https://github.com/VSCodium/vscodium/issues/new"
         | .licenseUrl="https://github.com/VSCodium/vscodium/blob/master/LICENSE"
         | .updateUrl=null
         | .backupUpdateUrl=null' \
        product.json > product.json.tmp
      mv product.json.tmp product.json

      # VSCodium's own product.json contributes the extension allowlists.
      jq -s '.[0] * .[1]' product.json ${vscodiumSrc}/product.json > product.json.tmp
      mv product.json.tmp product.json

      # The announcements patch left a marker in the welcome page; fill it in the
      # way prepare_vscode.sh does.
      node -e '
        const fs = require("fs");
        const file = "src/vs/workbench/contrib/welcomeGettingStarted/browser/gettingStarted.ts";
        const marker = "[/* BUILTIN_ANNOUNCEMENTS */]";
        const announcements = fs.readFileSync(process.argv[1], "utf8").replace(/\n/g, "");
        fs.writeFileSync(file, fs.readFileSync(file, "utf8").replace(marker, announcements));
      ' ${vscodiumSrc}/announcements-builtin.json

      # Web app manifest served by the remote server.
      jq '.name = "VSCodium" | .short_name = "VSCodium"' resources/server/manifest.json > manifest.json.tmp
      mv manifest.json.tmp resources/server/manifest.json

      substituteInPlace package.json --replace-fail 'Microsoft Corporation' 'VSCodium'
      # prepare_vscode.sh sets the package version to the VSCodium release.
      jq --arg version "${vscodiumTag}" '.version = $version' package.json > package.json.tmp
      mv package.json.tmp package.json

      # The bundle's NSHumanReadableCopyright and the win32 installer metadata
      # otherwise keep Microsoft's name; prepare_vscode.sh edits the same file.
      substituteInPlace build/lib/electron.ts \
        --replace-fail 'Microsoft Corporation' 'VSCodium'
      # The copyright line is "Copyright (C) <year> Microsoft", which the
      # company-name replacement above does not reach.
      sed -i -E 's|([0-9]) Microsoft|\1 VSCodium|g' build/lib/electron.ts

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

      # preinstall.ts runs before every npm rebuild and installs the Electron
      # headers through build/npm/gyp's own node-gyp, whose path it hardcodes, so
      # that workspace has to be installed first.
      if [ -f build/npm/gyp/package-lock.json ]; then
        (cd build/npm/gyp && npm ci --ignore-scripts && patchShebangs node_modules || true)
      fi

      # Points the rebuilds that honour it at nixpkgs' node-gyp.
      export npm_config_node_gyp="${lib.getExe node-gyp}"

      # build/npm/postinstall.ts skips the root workspace (it assumes the root
      # install already ran its scripts), so run the same script here as well;
      # otherwise root's native modules (policy-watcher, native-keymap, ...)
      # stay unbuilt and the app dies at startup looking for their .node files.
      npm-install-script
      patchShebangs node_modules build/node_modules || true

      node build/npm/postinstall.ts

      patchShebangs node_modules build/node_modules || true

      # undo_telemetry.sh, at the point upstream runs it: after the dependency
      # install, over the whole tree, so vendored code is covered too.
      while IFS= read -r telemetry_file; do
        sed -i -E 's|//[^/]+\.data\.microsoft\.com|//0\.0\.0\.0|g' "$telemetry_file"
      done < <(${ripgrep}/bin/rg --no-ignore --hidden -l '\.data\.microsoft\.com' . || true)

      if [ -f node_modules/@vscode/gulp-electron/src/download.js ]; then
        substituteInPlace node_modules/@vscode/gulp-electron/src/download.js \
          --replace-fail 'let downloadOpts = {' 'let downloadOpts = { unsafelyDisableChecksums: true,' || true
      fi

      # build.sh: compile in a prepack step, then run the platform packaging.
      node --run gulp -- vscode-min-prepack

      # Remove the Windows-only debugger binaries from the mac/linux package.
      rm -f .build/extensions/ms-vscode.js-debug/src/win32-app-container-tokens.*.node

      # Group Policy / MDM definitions; the packaging below picks them up from
      # .build/policies/${platform}.
      npm run copy-policy-dto --prefix build
      node build/lib/policies/policyGenerator.ts build/lib/policies/policyData.jsonc ${platform}

      # The reh gulp task fetches Node from nodejs.org unless this directory is
      # already populated; seed it with nixpkgs' Node to stay offline.
      node_version=$(sed -nE 's/^target="?([^"]+)"?$/\1/p' remote/.npmrc | head -1)
      node_seed=".build/node/v$node_version/${platform}-${arch}"
      mkdir -p "$node_seed"
      cp ${nodejs}/bin/node "$node_seed/node"
      chmod +x "$node_seed/node"

      node --run gulp -- vscode-${platform}-${arch}-min-packing

      # Remote server and its web variant, packaged from the same sources.
      node --run gulp -- vscode-reh-${platform}-${arch}-min-packing
      node --run gulp -- vscode-reh-web-${platform}-${arch}-min-packing
      mkdir -p "$reh/libexec"
      mv "../vscode-reh-${platform}-${arch}" "$reh/libexec/codium-server"
      mv "../vscode-reh-web-${platform}-${arch}" "$reh/libexec/codium-server-web"
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
(buildVscode {
  inherit
    commandLineArgs
    useVSCodeRipgrep
    pname
    ;

  inherit (vscodium-build) version;
  vscodeVersion = "1.143.1";

  executableName = "codium";
  # VSCodium's 00-binary-fix-name.patch renames the launcher from bin/code to
  # bin/${applicationName}.
  sourceExecutableName = "codium";
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
}).overrideAttrs
  (old: {
    postFixup =
      (old.postFixup or "")
      + ''
        # Ship the locally built remote server, so Remote-SSH, dev containers and
        # `codium serve-web` work without downloading a server at runtime.
        mkdir -p "$out/libexec" "$out/bin"
        cp -R ${vscodium-build.reh}/libexec/. "$out/libexec/"
        ln -sfn "$out/libexec/codium-server/bin/codium-server" "$out/bin/codium-server"
        ln -sfn "$out/libexec/codium-server-web/bin/codium-server" "$out/bin/codium-server-web"
      ''
      + lib.optionalString hostPlatform.isDarwin ''
        # fixup's strip leaves the launcher with an embedded signature that declares
        # resources the bundle no longer has, so launchd refuses to start the app
        # (no window, no crash report). Re-sign the bundle ad hoc afterwards.
        chmod -R u+w "$out/Applications/VSCodium.app"
        # generic.nix symlinks vscode's bundled ripgrep to nixpkgs, and codesign
        # rejects symlinks escaping the bundle, so materialize the target first.
        rg_link=$(find "$out/Applications/VSCodium.app" -type l -name rg | head -1)
        if [ -n "$rg_link" ]; then
          rm "$rg_link"
          cp ${ripgrep}/bin/rg "$rg_link"
          chmod +x "$rg_link"
        fi
        /usr/bin/codesign --force --deep --sign - "$out/Applications/VSCodium.app"
      '';
  })
