# Adapted from https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/sp/splayer/package.nix
{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  electron_41,
  rustPlatform,
  cargo,
  rustc,
  python3,
  pkg-config,
  alsa-lib,
  libclang,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  # nix-update-script,
  removeReferencesTo,
  autoPatchelfHook,
}:
let
  electron = electron_41;
  pnpm = pnpm_10; # pnpm_10_29_2 is insecure and Nix refuses to build it
in
stdenv.mkDerivation (finalAttrs: {
  pname = "splayer-next";
  version = "1.0.0-20260720";

  src = fetchFromGitHub {
    owner = "SPlayer-Dev";
    repo = "SPlayer-Next";
    rev = "78696e0b95eef6fee8d531c9814fdcefef299014"; # No releases yet
    fetchSubmodules = false;
    hash = "sha256-JQULU7rq5d9qZqoI6vbR+6om70b3MeyEc1kKLETC4s8=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-gLnJZMN4wLhfHOGOXXDSoZQiY6h5WhFLaunIeVuoOUg=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      ;
    hash = "sha256-pvB+OrpX/kuyMdH5NSh5/ueNEeYVY3yg2pGTZNLJ1+g=";
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm
    nodejs
    rustPlatform.cargoSetupHook
    cargo
    rustc
    python3
    makeWrapper
    copyDesktopItems
    pkg-config
    libclang
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    stdenv.cc.cc.lib
  ];

  strictDeps = true;
  __structuredAttrs = true;

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    LIBCLANG_PATH="${libclang.lib}/lib"; # Or cargo wouldn't find libclang.so
    BINDGEN_EXTRA_CLANG_ARGS = "-I${stdenv.cc.libc.dev}/include"; # to provide standard headers for bindgen
  };

  postPatch = ''
    # Workaround for https://github.com/electron/electron/issues/31121
    substituteInPlace electron/main/utils/nativeLoader.ts \
      --replace-fail 'process.resourcesPath' "'$out/share/splayer-next/resources'"
  '';

  buildPhase = ''
    runHook preBuild

    # After the pnpm configure, we need to build the binaries of all instances
    # of better-sqlite3. It has a native part that it wants to build using a
    # script which is disallowed.
    # What's more, we need to use headers from electron to avoid ABI mismatches.
    # Adapted from mkYarnModules.
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

    mkdir -p "$out/share/splayer-next"
    cp -Pr --no-preserve=ownership dist/*-unpacked/{locales,resources{,.pak}} $out/share/splayer-next

    _icon_sizes=(16x16 32x32 96x96 192x192 256x256 512x512)
    for _icons in "''${_icon_sizes[@]}";do
      install -D public/icons/favicon-$_icons.png $out/share/icons/hicolor/$_icons/apps/splayer-next.png
    done

    makeWrapper '${lib.getExe electron}' "$out/bin/splayer-next" \
      --add-flags $out/share/splayer-next/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "splayer-next";
      desktopName = "SPlayer Next";
      exec = "splayer-next %U";
      terminal = false;
      type = "Application";
      icon = "splayer-next";
      startupWMClass = "SPlayerNext";
      comment = "A minimalist music player";
      categories = [
        "AudioVideo"
        "Audio"
        "Music"
      ];
      mimeTypes = [ "x-scheme-handler/orpheus" ];
      extraConfig.X-KDE-Protocols = "orpheus";
    })
  ];
  meta = {
    description = "Simple Netease Cloud Music player, Next version";
    homepage = "https://github.com/SPlayer-Dev/SPlayer-Next";
    license = lib.licenses.agpl3Only;
    mainProgram = "splayer-next";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
    ];
  };
})
