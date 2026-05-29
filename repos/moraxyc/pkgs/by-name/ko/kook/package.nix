{
  lib,
  stdenvNoCC,
  requireFile,

  _7zz,
  electron,
  makeWrapper,
  asar,
  libicns,
  makeDesktopItem,
  copyDesktopItems,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kook";
  version = "0.0.6";

  src = requireFile {
    name = "KOOK.dmg";
    hash = "sha256-lUonTiC64zFP4h//yoYqwrfqLqNFq+iP4jS3cjEmo3U=";
    message = ''
      nix hash file $(nix-store --add-fixed sha256 KOOK.dmg)
    '';
  };

  nativeBuildInputs = [
    asar
    _7zz
    copyDesktopItems
    libicns
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  sourceRoot = ".";

  patchPhase = ''
    runHook prePatch

    asar extract KOOK.app/Contents/Resources/app.asar app-asar

    patch app-asar/src/browser_native/native/screenshot.js < ${./screenshot.patch}
    patch app-asar/src/browser_native/native/system-process.js < ${./system-process.patch}

    asar pack app-asar app.asar
    mv app.asar KOOK.app/Contents/Resources/app.asar

    find KOOK.app/Contents/Resources -name '*:com.apple.cs.*' -delete
    rm -rf KOOK.app/Contents/Resources/extra-app

    runHook postPatch
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    install -Dm644 KOOK.app/Contents/Resources/app.asar $out/share/kook/resources/app.asar

    cp -r KOOK.app/Contents/Resources/app.asar.unpacked $out/share/kook/resources/app.asar.unpacked

    icns2png -x ./KOOK.app/Contents/Resources/icon.icns
    for size in 32 64 128 256 512 1024; do
      dim="$size"x"$size"
      install -Dm644 \
        "icon_''${dim}x32.png" \
        "$out/share/icons/hicolor/$dim/apps/kook.png"
    done

    makeWrapper ${lib.getExe electron} "$out/bin/kook" \
      --add-flags "$out/share/kook/resources/app.asar" \
      --set-default ELECTRON_IS_DEV 0 \
      --set-default ELECTRON_OZONE_PLATFORM_HINT auto \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \

    runHook postInstall
  '';

  desktopItems = lib.singleton (makeDesktopItem {
    categories = [
      "Network"
      "Chat"
      "InstantMessaging"
    ];
    comment = "KOOK, a user-friendly voice communication tool";
    desktopName = "KOOK";
    exec = "kook %U";
    icon = "kook";
    name = "KOOK";
    startupWMClass = "KOOK";
    terminal = false;
    type = "Application";
  });

  meta = {
    description = "User-friendly voice communication tool";
    homepage = "https://www.kookapp.cn/";
    platforms = [ "x86_64-linux" ];
    mainProgram = "kook";
    license = lib.licenses.unfree;
  };
})
