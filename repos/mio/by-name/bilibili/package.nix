{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm,
  nodejs_22,
  asar,
  exiftool,
  p7zip,
  patchelf,
  electron,
  makeWrapper,
  commandLineArgs ? "",
  copyDesktopItems,
  makeDesktopItem,
  libva,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bilibili";
  version = "1.17.9-1";

  src = fetchFromGitHub {
    owner = "msojocs";
    repo = "bilibili-linux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qd/SBQ7NXhX8a7pIad6yCPrICNHZHhpc5WHVPjL+yME=";
  };

  bilibiliInstaller = fetchurl {
    url = "https://dl.hdslb.com/mobile/fixed/bili_win/bili_win-install.exe";
    hash = "sha256-FFzclZY9BoQ1VyoVrRWhxHl636QRCeiwix4FgH0UZKs=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-zxa1h3GoJofrkgZ6sBRBbk23Ptp9zlEcBpQzwsNGKig=";
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm
    nodejs_22
    asar
    exiftool
    p7zip
    patchelf
    makeWrapper
    copyDesktopItems
    writableTmpDirAsHomeHook
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    NPM_CONFIG_MANAGE_PACKAGE_MANAGER_VERSIONS = "false";
    CI = "true";
  };

  postPatch = ''
    patchShebangs tools/

    # Keep builds hermetic; pnpm otherwise tries to self-manage the configured version.
    substituteInPlace package.json \
      --replace-fail '"packageManager": "pnpm@10.2.1+sha512.398035c7bd696d0ba0b10a688ed558285329d27ea994804a52bad9167d8e3a72bcb993f9699585d3ca25779ac64949ef422757a6c31102c12ab932e5cbe5cc92"' '"_packageManager": "pnpm@10.2.1"'

    substituteInPlace tools/fix-other.sh \
      --replace-warn 'wget -c https://github.com/msojocs/bilibili-linux/releases/download/tools/cursor-tool -Ocursor-tool' "" \
      --replace-warn 'chmod +x cursor-tool' ""

    substituteInPlace tools/extension.sh \
      --replace-warn 'pnpm install' "" \
      --replace-warn 'pnpm run build' ""
  '';

  buildPhase = ''
    runHook preBuild

    # sass-embedded ships a prebuilt ELF with a FHS interpreter path; patch it for Nix.
    for dart_bin in $(find node_modules -type f -path '*/dart-sass/src/dart'); do
      patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} "$dart_bin"
    done

    pnpm run build

    mkdir cache
    cp "${finalAttrs.bilibiliInstaller}" cache/bili_win-install.exe

    bash tools/update-bilibili.sh
    bash tools/fix-other.sh
    bash tools/extension.sh

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 res/icons/256x256.png \
      $out/share/icons/hicolor/256x256/apps/bilibili.png

    mkdir -p $out/share/bilibili
    cp "$PWD/tmp/bili/resources/app.asar" $out/share/bilibili/app.asar
    cp -r app/extensions $out/share/bilibili/extensions
    cp app/transcribe.py $out/share/bilibili/transcribe.py

    makeWrapper ${lib.getExe electron} $out/bin/bilibili \
      --argv0 "bilibili" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libva ]} \
      --add-flags "$out/share/bilibili/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --add-flags "--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL" \
      --add-flags ${lib.escapeShellArg commandLineArgs}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "bilibili";
      desktopName = "Bilibili";
      exec = "bilibili %U";
      icon = "bilibili";
      categories = [
        "AudioVideo"
        "Video"
      ];
    })
  ];

  meta = {
    description = "Electron-based bilibili desktop client";
    homepage = "https://github.com/msojocs/bilibili-linux";
    license = with lib.licenses; [
      unfree
      mit
    ];
    maintainers = with lib.maintainers; [
      jedsek
      kashw2
      bot-wxt1221
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
    mainProgram = "bilibili";
  };
})
