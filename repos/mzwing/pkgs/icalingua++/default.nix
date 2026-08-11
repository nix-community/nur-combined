{
  lib,
  stdenv,
  source,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_10,
  nodejs,
  electron,
  python3,
  makeWrapper,
  xdg-utils,
}: let
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  # Vendored pnpm store hash. Refreshed by the update pipeline
  # (scripts/package-updates/update-hashes.nix drives nix-update, which
  # rebuilds the pnpmDeps FOD with a blanked hash and rewrites this
  # value in place). fetchPnpmDeps passes --force to pnpm install, so
  # optional dependencies of every platform are vendored and a single
  # hash covers both x86_64-linux and aarch64-linux.
  pnpmDepsHash = "sha256-/SX3bUNUv/QPGu8/c/glk0KBtre87h1OXdQvHXbDss8=";
in
  stdenv.mkDerivation {
    inherit pname src version;

    # Detached electron packaging (like the AUR icalingua++-electron-git
    # variant): only app.asar is shipped and nixpkgs' electron runs it.
    # Upstream pins electron 38, which nixpkgs has already removed (39/40
    # are flagged EOL/insecure), so the default nixpkgs electron is used
    # instead. The only native module (sqlite3) is an N-API module
    # compiled against this very electron's headers below, so it loads
    # under any recent Electron regardless of ABI; the risk profile is
    # limited to upstream app code vs. newer Electron runtime behavior.
    pnpmDeps = fetchPnpmDeps {
      inherit pname version src;
      pnpm = pnpm_10;
      fetcherVersion = 4;
      hash = pnpmDepsHash;
    };

    nativeBuildInputs = [
      makeWrapper
      nodejs
      pnpm_10
      pnpmConfigHook
      python3 # node-gyp
    ];

    env = {
      # The electron npm package's postinstall would otherwise download a
      # prebuilt Electron binary; nixpkgs' electron is used instead.
      ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

      # pnpmConfigHook installs with --ignore-scripts, so nothing builds
      # the native sqlite3 module; the explicit node-pre-gyp rebuild in
      # preBuild is its only producer. These variables make the node-gyp
      # that node-pre-gyp shells out to work offline against the Electron
      # headers shipped by nixpkgs' electron package (electron.headers).
      # sqlite3 is an N-API module (binary.napi_versions), so the result
      # is not tied to a specific Electron ABI.
      npm_config_runtime = "electron";
      npm_config_target = electron.version;
      npm_config_nodedir = "${electron.headers}";
    };

    preBuild = ''
      # Upstream .npmrc sets node-linker=hoisted + shamefully-hoist, so
      # everything lives in a flat root node_modules (which upstream's own
      # scripts, e.g. deps:woa:sqlite3, also rely on).
      #
      # Build sqlite3's native module from source through its own
      # @mapbox/node-pre-gyp (hoisted to the root node_modules) instead
      # of bare node-gyp: node-pre-gyp expands the N-API build versions
      # declared in sqlite3's binary.napi_versions, injects module_path
      # and the other gyp variables its binding.gyp needs, and the
      # action_after_build target then copies node_sqlite3.node into
      # lib/binding/napi-v*-linux-*-<arch>/, which is exactly where the
      # runtime node-pre-gyp lookup expects it. No prebuilt binary is
      # downloaded and no Node/Electron ABI is hardcoded. node-pre-gyp
      # finds node-gyp next to the npm bundled with nixpkgs' nodejs, so
      # the compile stays offline in the sandbox (headers come from
      # npm_config_nodedir above).
      pushd node_modules/sqlite3
      node ../@mapbox/node-pre-gyp/bin/node-pre-gyp rebuild
      popd
    '';

    buildPhase = ''
      runHook preBuild

      cd icalingua
      # rspack bundle (dist/electron), then electron-builder --dir for the
      # asar. electronDist/electronVersion make electron-builder fully
      # offline (no Electron zip download); --dir only produces the
      # unpacked directory, so no AppImage/fpm tooling is fetched either.
      # Upstream's afterPack.cjs fixes pnpm-hoisting-induced missing deps
      # inside the asar and unpacks *.node (sqlite3) automatically.
      pnpm run build:ci
      pnpm exec electron-builder --dir \
        -c.electronDist=${electron.dist} \
        -c.electronVersion=${electron.version}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      # Still in icalingua/ from buildPhase. The output directory is
      # linux-unpacked on x86_64 and linux-arm64-unpacked on aarch64.
      mkdir -p $out/lib/icalingua
      cp -r build/linux*-unpacked/resources/app.asar* $out/lib/icalingua/

      install -Dm644 ../pkgres/512x512.png \
        $out/share/icons/hicolor/512x512/apps/icalingua.png
      install -Dm644 ../pkgres/icalingua.desktop \
        $out/share/applications/icalingua.desktop

      # Wayland support follows the nixpkgs electron convention: only
      # active when the user opts in via NIXOS_OZONE_WL (upstream default
      # behavior, X11/XWayland, is otherwise unchanged). The \ before
      # ''${NIXOS_OZONE_WL...} keeps the parameter expansion literal so
      # it is evaluated by the wrapper at runtime; without it bash would
      # expand it to empty here in the build sandbox.
      makeWrapper ${lib.getExe electron} $out/bin/icalingua \
        --add-flags "$out/lib/icalingua/app.asar" \
        --add-flags "\''${NIXOS_OZONE_WL:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime}" \
        --prefix PATH : ${lib.makeBinPath [xdg-utils]}

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      test -x $out/bin/icalingua
      test -f $out/lib/icalingua/app.asar
      test -f $out/share/applications/icalingua.desktop
      test -f $out/share/icons/hicolor/512x512/apps/icalingua.png

      # The native module must have been unpacked from the asar (the asar
      # cannot host .node files) and must load under the runtime
      # Electron. ELECTRON_RUN_AS_NODE turns electron into a plain Node.js
      # runtime, so this works headless in the sandbox.
      node_module="$(find $out/lib/icalingua/app.asar.unpacked -name 'node_sqlite3.node' | head -n1)"
      test -n "$node_module"
      ELECTRON_RUN_AS_NODE=1 ${lib.getExe electron} -e "require('$node_module')"

      # The wrapper must point at the asar and carry the Wayland flags.
      grep -F "$out/lib/icalingua/app.asar" $out/bin/icalingua
      grep -F 'NIXOS_OZONE_WL' $out/bin/icalingua

      runHook postInstallCheck
    '';

    meta = {
      description = "A client for QQ and more";
      homepage = "https://github.com/Icalingua-plus-plus/Icalingua-plus-plus";
      changelog = "https://github.com/Icalingua-plus-plus/Icalingua-plus-plus/releases/tag/v${version}";
      license = lib.licenses.agpl3Only;
      mainProgram = "icalingua";
      maintainers = [
        {
          name = "mzwing";
        }
      ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  }
