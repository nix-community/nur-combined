{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpm_10_29_2,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  electron_39,
  rustPlatform,
  cargo,
  rustc,
  python3,
  pkg-config,
  openssl,
  ffmpeg,
  alsa-lib,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  nix-update-script,
  removeReferencesTo,
}:
let
  electron = electron_39;
  pnpm = pnpm_10_29_2;
  shareDir = "$out/share/SPlayer-Next";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "splayer-next";
  version = "";

  src = fetchFromGitHub {
    owner = "SPlayer-Dev";
    repo = "SPlayer-Next";
    tag = "v${finalAttrs.version}";
    hash = "";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      ;
    hash = "";
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm
    nodejs
    rustPlatform.cargoSetupHook
    rustPlatform.bindgenHook
    cargo
    rustc
    python3
    makeWrapper
    copyDesktopItems
    pkg-config
  ];

  buildInputs = [
    openssl
    ffmpeg
    alsa-lib
  ]
  # make linker happy
  ++ ffmpeg.buildInputs;

  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  CARGO_PROFILE_RELEASE_LTO = "false";

  postPatch = ''
    # Workaround for https://github.com/electron/electron/issues/31121
    substituteInPlace electron/main/utils/nativeLoader.ts \
      --replace-fail 'process.resourcesPath' "'${shareDir}/resources'";
  '';

  buildPhase = ''
    runHook preBuild

    # After the pnpm configure, we need to build the binaries of all instances
    # of better-sqlite3. It has a native part that it wants to build using a
    # script which is disallowed.
    # What's more, we need to use headers from electron to avoid ABI mismatches.
    for f in $(find . -path '*/node_modules/better-sqlite3' -type d); do
        (cd "$f" && (
        npm run build-release --offline --nodedir="${electron.headers}"
        rm -rf build/Release/{.deps,obj,obj.target,test_extension.node}
        find build -type f -exec \
        ${lib.getExe removeReferencesTo} \
        -t "${electron.headers}" {} \;
        ))
    done

    pnpm build

    npm exec electron-builder -- \
        --dir \
        --config electron-builder.config.ts \
        -c.electronDist=${electron.dist} \
        -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "${shareDir}"
    cp -Pr --no-preserve=ownership dist/*-unpacked/{locales,resources{,.pak}} "${shareDir}"

    _icon_sizes=(16x16 32x32 96x96 192x192 256x256 512x512)
    for _icons in "''${_icon_sizes[@]}";do
      install -D public/icons/favicon-$_icons.png $out/share/icons/hicolor/$_icons/apps/SPlayer-Next.png
    done

    makeWrapper '${lib.getExe electron}' "$out/bin/SPlayer-Next" \
      --add-flags "${shareDir}/resources/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "splayer";
      desktopName = "SPlayer Next";
      exec = "SPlayer-Next %U";
      terminal = false;
      type = "Application";
      icon = "SPlayer-Next";
      startupWMClass = "SPlayer Next";
      comment = "A minimalist music player";
      categories = [
        "AudioVideo"
        "Audio"
        "Music"
      ];
      # mimeTypes = [ "x-scheme-handler/orpheus" ];
      # extraConfig.X-KDE-Protocols = "orpheus";
    })
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Simple Netease Cloud Music player";
    homepage = "https://github.com/SPlayer-Dev/SPlayer-Next";
    changelog = "https://github.com/SPlayer-Dev/SPlayer-Next/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "SPlayer-Next";
    platforms = lib.platforms.linux;
  };
})
