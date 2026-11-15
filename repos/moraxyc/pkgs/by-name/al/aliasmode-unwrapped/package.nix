{
  lib,
  rustPlatform,
  callPackage,
  aliasmode-firefox-bin,
  aliasmode-chromium-bin,
  bun,
  nodejs,
  pkg-config,
  openssl,
  gtk3,
  webkitgtk_4_1,
  jq,
  unzip,
  makeDesktopItem,
  copyDesktopItems,
  sources,
  source ? sources.aliasmode,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aliasmode-unwrapped";
  inherit (source) version src;
  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoHash = source.cargoHash or lib.fakeHash;
  cargoBuildFlags = [ "--features=tauri/custom-protocol" ];

  nodeModules = callPackage ./node-modules.nix { inherit source; };
  firefox = aliasmode-firefox-bin.override { inherit source; };
  chromium = aliasmode-chromium-bin.override { inherit source; };
  patches = [ ./packaged-chromium.patch ];

  nativeBuildInputs = [
    bun
    pkg-config
    jq
    unzip
    copyDesktopItems
  ];
  buildInputs = [
    openssl
    gtk3
    webkitgtk_4_1
  ];

  postPatch = ''
    substituteInPlace aliasmode-chromium.ts \
      --replace-fail '@aliasmodeChromiumExecutable@' '${finalAttrs.chromium.executable}'
    substituteInPlace src-tauri/src/lib.rs \
      --replace-fail 'let resource_dir = app.path().resource_dir()?;' \
        "let resource_dir = std::path::PathBuf::from(\"$out/lib/aliasmode\");"
    substituteInPlace scripts/prepare-windows-bundle.ts \
      --replace-fail 'cpSync(source, destination, { recursive: true });' \
        'cpSync(source, destination, { recursive: true, verbatimSymlinks: true });'
    substituteInPlace src-tauri/src/releases.rs \
      --replace-fail 'if !cfg!(any(' 'if true || !cfg!(any(' \
      --replace-fail 'AliasMode updates are not available on this system.' 'AliasMode is managed by Nix; update it through your Nix configuration.'
    # Resources are installed by Nix, not copied into Cargo's target tree by Tauri.
    jq '.bundle.createUpdaterArtifacts = false | .bundle.icon = ["icons/icon.png"] | del(.bundle.resources)' \
      src-tauri/tauri.conf.json > tauri.conf.json.tmp
    mv tauri.conf.json.tmp src-tauri/tauri.conf.json
  '';

  preBuild = ''
    export HOME="$TMPDIR"
    cp -R ${finalAttrs.nodeModules} node_modules
    chmod -R u+w node_modules
    mkdir -p src-tauri/{binaries,generated,resources/playwright/node}
    ln -sf ${lib.getExe nodejs} src-tauri/resources/playwright/node/node
    unzip -j ${bun.sources.x86_64-linux} '*/bun' -d "$TMPDIR/bun-runtime"
    substituteInPlace scripts/prepare-windows-bundle.ts \
      --replace-fail '"--compile",' \
        "\"--compile\", \"--compile-executable-path=$TMPDIR/bun-runtime/bun\","
    bun -e 'import { compileSidecar, stageAgentRuntime } from "./scripts/prepare-windows-bundle.ts"; await compileSidecar(process.cwd(), "src-tauri/binaries/aliasmode-sidecar-x86_64-unknown-linux-gnu", "bun-linux-x64-baseline"); stageAgentRuntime(process.cwd(), "src-tauri/resources/playwright");'
    jq '{firefox: (.firefox | del(.url))}' ${
      source.artifacts."browser-runtime.json"
    } > src-tauri/generated/browser.json
    printf '%s\n' '${finalAttrs.version}' > src-tauri/generated/VERSION.txt
  '';

  postInstall = ''
    install -Dm755 src-tauri/binaries/aliasmode-sidecar-* $out/bin/aliasmode-sidecar
    mkdir -p $out/lib/aliasmode
    ln -s ${finalAttrs.firefox}/lib/aliasmode-firefox $out/lib/aliasmode/firefox
    cp -R src-tauri/resources/playwright $out/lib/aliasmode/
    install -Dm644 src-tauri/icons/icon.png $out/share/icons/hicolor/256x256/apps/aliasmode.png
  '';

  # Bun embeds the sidecar program in its executable.
  dontStrip = true;
  desktopItems = [
    (makeDesktopItem {
      name = "aliasmode";
      desktopName = "AliasMode";
      comment = "Local-first browser profile manager";
      exec = "aliasmode";
      icon = "aliasmode";
      categories = [
        "Network"
        "WebBrowser"
      ];
    })
  ];

  passthru.fetchrix.nodeModules = finalAttrs.nodeModules.overrideAttrs {
    # Fetchrix supplies the prepared source, so it must not apply this patch twice.
    patches = [ ];
  };

  meta = {
    description = "Local-first browser profile manager with patched Firefox and Chromium engines";
    homepage = "https://github.com/aliasmode/aliasmode";
    license = with lib.licenses; [
      asl20
      mpl20
    ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "aliasmode";
  };
})
