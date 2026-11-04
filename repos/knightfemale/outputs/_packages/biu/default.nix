{
  lib,
  stdenv,
  asar,
  copyDesktopItems,
  electron,
  fetchFromGitHub,
  fetchPnpmDeps,
  ffmpeg-headless,
  fontconfig,
  makeDesktopItem,
  makeWrapper,
  nodejs_22,
  pnpm_10,
  pnpmBuildHook,
  pnpmConfigHook,
  util-linux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "biu";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "wood3n";
    repo = "biu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ORLdGSkeWM89IkbY6zeTevTscAZMIWNOW5nsa0BWzUs=";
  };

  # Upstream lists the whole renderer dependency tree
  # (react/@heroui/zod/moment/…) under `dependencies`,
  # even though it is only consumed at build time by rsbuild
  # and never resolved from node_modules at runtime.
  # Without moving it aside, `pnpm install --prod` drags ~60 MiB
  # of frontend packages into app.asar.
  patches = [ ./0001-move-frontend-deps.patch ];

  # Besides the hoist pattern, upstream's .npmrc sets engine-strict=true
  # while package.json pins engines.node to the exact version "22.17.1"
  # pnpm >= 11 ignores the whole .npmrc,so that check never ran.
  # with pnpm_10 pinned it does and it cannot be satisfied
  # (nixpkgs' nodejs_22 is 22.23.3 and pnpm_10 bundles Node 24.x).
  # The runtime Node is nixpkgs' choice, so disable the check.
  # This flag is read by pnpmConfigHook and is forwarded to fetchPnpmDeps below,
  # which needs it separately (build-time-only env vars do not reach that derivation).
  pnpmInstallFlags = [ "--config.engine-strict=false" ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      patches
      pnpmInstallFlags
      ;
    pnpm = pnpm_10;
    fetcherVersion = 4;
    hash = "sha256-1F78X0h6jovVxs4c6240esfr/SwWJjqculKZi0nye9U=";
  };

  nativeBuildInputs = [
    asar
    copyDesktopItems
    makeWrapper
    nodejs_22
    pnpm_10
    pnpmBuildHook
    pnpmConfigHook
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    # rsbuild's config imports "electron" (via plugins/electron-dev.ts),
    # that npm shim only resolves a binary path when ELECTRON_OVERRIDE_DIST_PATH is set.
    ELECTRON_OVERRIDE_DIST_PATH = electron.dist;
    # Same reason as pnpmInstallFlags above,
    # but for every pnpm invocation during the build:
    # `pnpm install` (pnpmConfigHook), `pnpm run build` (pnpmBuildHook)
    # and the `pnpm install --prod` in postBuild.
    # None of them read pnpmInstallFlags,
    # so without this they all trip over engines.node.
    # pnpm 10 reads the npm_config_* prefix,
    # pnpm_config_engine_strict was tried first and had no effect.
    # pnpm >= 11 only honours pnpm_config_* (and puts non-auth settings in pnpm-workspace.yaml),
    # so this needs revisiting if the pinned pnpm is ever bumped.
    npm_config_engine_strict = "false";
  };

  postPatch = ''
    # Hard-code the runtime resourcesPath to the store path (ente-desktop pattern,
    # only electron/utils.ts:12,:64 reference it in the whole tree)
    substituteInPlace electron/utils.ts \
      --replace-fail "process.resourcesPath" "\"$out/share/biu/resources\""

    # Disable auto-update in production (a nixpkgs build has no app-update.yml,
    # otherwise checkForUpdates fails with ENOENT)
    substituteInPlace electron/updater/index.ts \
      --replace-fail 'autoUpdater.logger = log;' 'if (!isDev) return; // nixpkgs: auto-update disabled
      autoUpdater.logger = log;'

    # Skip the electron-builder call inside the rsbuild plugin,
    # the payload is assembled by postBuild instead (see below)
    substituteInPlace plugins/rsbuild-plugin-electron.ts \
      --replace-fail "await buildElectron();" "// await buildElectron();"
  '';

  pnpmBuildScript = "build"; # rsbuild emits .electron/ + dist/web/

  postBuild = ''
    # Self-check: HeroUI's utility classes must be present in the built CSS.
    # Upstream src/app.css:6 emits them (e.g. `data-[loaded=true]:opacity-100`)
    # only when @heroui/theme is public-hoisted into the root node_modules;
    # if that silently stops happening (see the pnpm_10 note above) the glob
    # matches no file and covers/avatars stay at opacity: 0.
    # Fail the build here instead of shipping a silently broken UI.
    cssDir="dist/web/static/css"
    if [ ! -d "$cssDir" ]; then
      echo "ERROR: $cssDir does not exist - the web build produced no CSS." >&2
      exit 1
    fi

    # Match either the escaped class name or the emitted attribute selector,
    # e.g. `.data-\[loaded\=true\]\:opacity-100[data-loaded=true]`.
    # A regex is used instead of the literal `loaded\=true`
    # so the check keeps working if the Nix escaping of the pattern is ever changed.
    if ! grep -rqE 'data-loaded(=|=")true' "$cssDir"; then
      echo "ERROR: HeroUI utility classes are missing from $cssDir/*.css" >&2
      echo "       Tailwind's @source scan of @heroui/theme produced nothing." >&2
      echo "       Check that the pinned pnpm still public-hoists @heroui/theme." >&2
      exit 1
    fi

    # electron-builder 26.3.3's pnpm collector drops transitive dependencies
    # under pnpm >= 10.29.3 (it de-duplicates repeated nodes from `pnpm ls`, e.g.
    # music-metadata -> strtok3 -> token-types -> ieee754),
    # which ends in ERR_MODULE_NOT_FOUND at runtime.
    # Reinstall a flat (hoisted) production dependency tree instead
    # and let asar pack it, bypassing that collector.
    rm -rf node_modules
    pnpm install --prod --node-linker=hoisted --ignore-scripts --offline \
      --frozen-lockfile
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/biu/resources

    # Assemble the app directory (the asar root)
    mkdir -p payload/dist
    cp package.json payload/
    mv .electron payload/
    mv dist/web payload/dist/
    mv node_modules payload/
    chmod -R u+w payload

    # .bin symlinks are useless at runtime, and asar only accepts in-package links
    rm -rf payload/node_modules/.bin
    # pnpm build metadata contains a random storeDir,
    # build timestamps and build paths,
    # which would break reproducibility
    rm -f payload/node_modules/.modules.yaml \
      payload/node_modules/.pnpm-workspace-state-v1.json
    # only a copy of the lockfile, unused at runtime
    rm -rf payload/node_modules/.pnpm

    ${lib.getExe asar} pack payload $out/share/biu/resources/app.asar

    # Equivalent of electron-builder's extraResources
    mkdir -p $out/share/biu/resources/.electron
    cp -r electron/icons $out/share/biu/resources/.electron/icons
    mkdir -p $out/share/biu/resources/electron/ffmpeg
    ln -s ${lib.getExe ffmpeg-headless} $out/share/biu/resources/electron/ffmpeg/ffmpeg-linux

    install -Dm644 electron/icons/logo.png $out/share/icons/hicolor/512x512/apps/biu.png

    makeWrapper ${lib.getExe electron} $out/bin/biu \
      --set ELECTRON_FORCE_IS_PACKAGED 1 \
      --set ELECTRON_IS_DEV 0 \
      --add-flags "$out/share/biu/resources/app.asar" \
      --prefix PATH : ${
        lib.makeBinPath [
          fontconfig
          util-linux
        ]
      } \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "biu";
      exec = finalAttrs.meta.mainProgram;
      icon = "biu";
      startupWMClass = "Biu";
      desktopName = "Biu";
      comment = finalAttrs.meta.description;
      categories = [
        "Audio"
      ];
    })
  ];

  meta = {
    description = "Bilibili music desktop client";
    homepage = "https://github.com/wood3n/biu";
    license = {
      fullName = "PolyForm Noncommercial License 1.0.0";
      url = "https://polyformproject.org/licenses/noncommercial/1.0.0";
      free = false;
    };
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = with lib.maintainers; [ knightfemale ];
    mainProgram = "biu";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
