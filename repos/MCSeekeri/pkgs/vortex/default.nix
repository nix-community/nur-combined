{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_11,
  nodejs_24,
  python3,
  gnumake,
  pkg-config,
  jq,
  yq-go,
  gzip,
  patchelf,
  dotnet-runtime_9,
  electron_44,
  wine,
  fontconfig,
  makeWrapper,
  xdg-utils,
  makeDesktopItem,
  copyDesktopItems,
  nix-update-script,
}:

let
  pname = "vortex";
  version = "2.11.0";
  vortexLinuxVersion = "2.11.0-1";

  src = fetchFromGitHub {
    owner = "Nexus-Mods";
    repo = "Vortex";
    tag = "v${version}";
    hash = "sha256-5voRkJEIJr8WguThCmpO3rPHcMkr7Biq3nl7KBodrAM=";
  };

  vortexLinux = fetchFromGitHub {
    owner = "Arkazzae";
    repo = "VortexLinux";
    tag = "v${vortexLinuxVersion}";
    hash = "sha256-JnWz7ABJNU7Ocgi+kcBHT5SrbV0oiBx6+WOny6MSkY8=";
  };

  patchWorkspace = ''
    ${lib.getExe yq-go} -i '.engineStrict = false' pnpm-workspace.yaml
    ${lib.getExe yq-go} -i 'del(.engines.runtime) | del(.devEngines.runtime)' package.json
    ${lib.getExe yq-go} -i 'del(.importers.".".dependencies.node) | del(.packages."node@runtime:24.22.1") | del(.snapshots."node@runtime:24.22.1")' pnpm-lock.yaml
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 5;
    prePnpmInstall = patchWorkspace + ''
      export ELECTRON_SKIP_BINARY_DOWNLOAD=1
      export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
      pnpm fetch --frozen-lockfile --ignore-scripts || true
    '';
    nativeBuildInputs = [ yq-go ];
    hash = "sha256-X1Yq2KmYJqy0ky280Sj3zPMqrI2FfVFFK3b++Lom8/E=";
  };

  duckdbVersion = "1.5.1";
  duckdbExtension = fetchurl {
    url = "https://nexus-mods.github.io/duckdb-level-pivot/current_release/v${duckdbVersion}/linux_amd64/level_pivot.duckdb_extension.gz";
    hash = "sha256-+CKjeCbhl1VXrv+7MPwaea1KEEi0VaQpugtr8DEBMGU=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit
    pname
    version
    src
    pnpmDeps
    ;

  nativeBuildInputs = [
    nodejs_24
    pnpm_11
    pnpmConfigHook
    (python3.withPackages (ps: [ ps.setuptools ]))
    gnumake
    pkg-config
    jq
    yq-go
    gzip
    patchelf
    makeWrapper
    copyDesktopItems
    electron_44.headers
  ];

  buildInputs = [
    fontconfig.dev
    fontconfig.lib
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    VORTEX_ELECTRON_REBUILD = "skip";
    VORTEX_SKIP_SUBMODULES = "1";
    NX_DAEMON = "false";
    NX_NO_CLOUD = "true";
    NX_TUI = "false";
    pnpm_config_pm_on_fail = "ignore";
    pnpm_config_trust_lockfile = "true";
    pnpm_config_offline = "true";
    CI = "1";
    HUSKY = "0";
    NODE_ENV = "production";
  };

  postPatch = patchWorkspace + ''
    for compatibilityPatch in ${vortexLinux}/patches/*.patch; do
      patch -p1 --batch < "$compatibilityPatch"
    done

    jq '.version = "${version}"' src/main/package.json > package.json.tmp
    mv package.json.tmp src/main/package.json
    jq '.version = "${version}"' packages/vortex-api/package.json > package.json.tmp
    mv package.json.tmp packages/vortex-api/package.json

    substituteInPlace src/main/src/cli.ts \
      --replace-fail '.opts() as IParameters;' '.opts() as IParameters; const positionalNxm = argv.find((arg) => arg.startsWith("nxm://")); if (commandLine.download === undefined && commandLine.install === undefined && positionalNxm !== undefined) { commandLine.download = positionalNxm; }'

    substituteInPlace src/renderer/src/util/storeLookup.ts \
      --replace-fail 'appId: string | string[],' 'appId: string | string[] | number,' \
      --replace-fail 'if (!validInput(appId)) {' 'if (!validInput(typeof appId === "number" ? String(appId) : appId)) {' \
      --replace-fail 'findGameEntry(stores, "id", appId, storeId)' 'findGameEntry(stores, "id", typeof appId === "number" ? String(appId) : appId, storeId)'

    jq '.platforms = [ "linux_amd64" ]' src/main/duckdb-extensions.json > duckdb.json
    mv duckdb.json src/main/duckdb-extensions.json
    mkdir -p src/main/build/duckdb-extensions/v${duckdbVersion}/linux_amd64
    gunzip -c ${duckdbExtension} > \
      src/main/build/duckdb-extensions/v${duckdbVersion}/linux_amd64/level_pivot.duckdb_extension

    mkdir -p extensions/quickbms-support/dependencies

    install -Dm755 ${./dotnetprobe.sh} tools/dotnetprobe/dist/dotnetprobe
    : > tools/dotnetprobe/build.mjs
    jq '.targets.build.inputs = [
          "{projectRoot}/dotnetprobe.csproj",
          "{projectRoot}/Program.cs"
        ]' tools/dotnetprobe/project.json > dotnetprobe-project.json
    mv dotnetprobe-project.json tools/dotnetprobe/project.json
  '';

  buildPhase = ''
    runHook preBuild

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    export PATH="$PWD/node_modules/.bin:$PATH"
    export pnpm_config_store_dir="$STORE_PATH"
    find . -path '*/node_modules/.bin/node' -delete

    cat > "$HOME/.npmrc" <<NPMRC
    nodedir=${electron_44.headers}
    runtime=electron
    target=${electron_44.version}
    build_from_source=true
    NPMRC

    for spec in font-scanner @nexusmods/fomod-installer-native loot drivelist xxhash-addon; do
      prefix=$(echo "$spec" | tr '/' '+')
      dir=$(find node_modules/.pnpm -maxdepth 1 -type d -name "$prefix@*" | head -n 1)
      (cd "$dir/node_modules/$spec" && npm rebuild --foreground-scripts)
    done

    pnpm nx run @vortex/main:build --output-style=static

    pnpm_config_ignore_scripts=true pnpm nx run @vortex/main:publish --output-style=static
    patchShebangs src/main/dist/node_modules
    for spec in @nexusmods/fomod-installer-native drivelist xxhash-addon leveldown @parcel/watcher winapi-bindings; do
      (cd "src/main/dist/node_modules/$spec" && npm rebuild --foreground-scripts)
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    appdir="$out/lib/vortex/resources/app"
    mkdir -p "$appdir" "$out/lib/vortex/resources/locales"
    cp -r src/main/dist/build/. "$appdir/"
    mv src/main/dist/node_modules "$appdir/node_modules"
    cp -r locales/. "$out/lib/vortex/resources/locales/"

    gccLib="${stdenv.cc.cc.lib}/lib"
    fomod="$appdir/node_modules/@nexusmods/fomod-installer-native/build/Release"
    loot="$appdir/assets/loot/build/Release"
    if [ ! -f "$fomod/modinstaller.node" ] || [ ! -f "$loot/node-loot.node" ]; then
      echo "native addons were not built" >&2
      exit 1
    fi
    patchelf --set-rpath "\$ORIGIN:$gccLib" "$fomod/modinstaller.node" "$loot/node-loot.node"
    find "$appdir" -name fontmanager.node \
      -exec patchelf --set-rpath "\$ORIGIN:${fontconfig.lib}/lib:$gccLib" {} +

    install -Dm644 assets/images/vortex.png \
      "$out/share/icons/hicolor/512x512/apps/vortex.png"

    makeWrapper ${lib.getExe electron_44} "$out/bin/vortex" \
      --add-flags "--app=$appdir" \
      --set CHROME_DESKTOP com.nexusmods.vortex.desktop \
      --prefix PATH : ${
        lib.makeBinPath [
          dotnet-runtime_9
          xdg-utils
          wine
        ]
      } \
      --set DOTNET_ROOT "${dotnet-runtime_9}/share/dotnet" \
      --set VORTEX_WINE "${lib.getExe wine}" \
      --prefix LD_LIBRARY_PATH : ${stdenv.cc.cc.lib}/lib

    runHook postInstall
  '';

  postFixup = ''
    gunzip -c ${duckdbExtension} > \
      "$out/lib/vortex/resources/app/duckdb-extensions/v${duckdbVersion}/linux_amd64/level_pivot.duckdb_extension"

    find "$out/lib/vortex/resources/app" -name '*.node' -print0 |
      while IFS= read -r -d "" f; do
        patchelf --set-rpath '$ORIGIN:${fontconfig.lib}/lib:${stdenv.cc.cc.lib}/lib' "$f" 2>/dev/null || true
      done
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "com.nexusmods.vortex";
      desktopName = "Vortex";
      genericName = "Mod Manager";
      comment = "Mod manager from Nexus Mods";
      exec = "vortex %U";
      icon = "vortex";
      categories = [
        "Game"
        "Utility"
      ];
      extraConfig = {
        MimeType = "x-scheme-handler/nxm;";
      };
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Mod manager from Nexus Mods with VortexLinux compatibility patches";
    homepage = "https://github.com/Arkazzae/VortexLinux";
    changelog = "https://github.com/Nexus-Mods/Vortex/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "vortex";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
