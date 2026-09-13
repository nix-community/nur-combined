{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchurl,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  autoPatchelfHook,
  icoutils,
  electron_9,
  nix-update-script,
  stdenv,
}:
################################################################################
# Mostly based on flashbrowser package from AUR:
# https://aur.archlinux.org/packages/flashbrowser
################################################################################
let
  version = "0.81";

  flashPlugin = fetchurl {
    url = "https://github.com/darktohka/clean-flash-builds/releases/download/v1.7/flash_player_patched_ppapi_linux.x86_64.tar.gz";
    hash = "sha256-/KT9CPQGOfxJXD9YoYd+fqAjzLGfCmRmo5bkGN7loYY=";
  };
in
buildNpmPackage (finalAttrs: {
  pname = "flashbrowser";
  inherit version;

  src = fetchFromGitHub {
    owner = "radubirsan";
    repo = "FlashBrowser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TAGH/vZGXgfF/Ul98E7sqJjhIP7vN9loUhDMJLHIfPk=";
  };

  npmDepsHash = "sha256-Enik+LGjTz0GlLDVNUILkrQ9mqRGe7f3jnf6S/DpxkI=";

  npmFlags = [ "--legacy-peer-deps" ];
  npmInstallFlags = [ "--omit=dev" ];
  npmRebuildFlags = [ "--ignore-scripts" ];

  dontNpmBuild = true;

  prePatch = ''
    sed -i 's/\r$//' index.js
  '';

  patches = [
    ./cli-arg.patch
    ./default-homepage.patch
  ];

  postPatch = ''
    rm -rf flashver
    mkdir flashver
    rm -f .DS_Store ._package.json .gitignore
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    icoutils
    makeWrapper
  ];

  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    appDir=$out/share/flashbrowser
    mkdir -p $appDir/flashver $out/bin $out/share/licenses/flashbrowser

    cp -r index.js store.js browser.html settings.html package.json icons themes node_modules $appDir/

    tar -xf ${flashPlugin} -C $appDir/flashver libpepflashplayer.so
    tar -xf ${flashPlugin} -C $out/share/licenses/flashbrowser license.pdf readme.txt manifest.json LGPL

    makeWrapper ${electron_9}/bin/electron $out/bin/FlashBrowser \
      --set GDK_BACKEND x11 \
      --add-flags $appDir

    iconDir=$(mktemp -d)
    icotool -x -o "$iconDir" icon.ico
    for size in 16 24 32 48 256; do
      icon=$(find "$iconDir" -name "*_''${size}x''${size}x*.png" | head -n1)
      install -Dm644 "$icon" $out/share/icons/hicolor/''${size}x''${size}/apps/FlashBrowser.png
    done

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "FlashBrowser";
      desktopName = "FlashBrowser";
      exec = "FlashBrowser %U";
      terminal = false;
      icon = "FlashBrowser";
      startupWMClass = "FlashBrowser";
      comment = "Browser for Flash Player games";
      categories = [ "Utility" ];
      mimeTypes = [
        "application/x-shockwave-flash"
        "application/x-shockwave-flash2-preview"
        "application/vnd.adobe.flash-movie"
      ];
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Browser capable of viewing pages with embedded Flash content";
    homepage = "https://github.com/radubirsan/FlashBrowser";
    license = with lib.licenses; [
      isc
      unfreeRedistributable
    ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "FlashBrowser";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
