{
  callPackage,
  copyDesktopItems,
  dpkg,
  electron,
  lib,
  makeDesktopItem,
  makeWrapper,
  source ? callPackage ./source.nix { },
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "haimacloud";
  inherit (source) version src;

  strictDeps = true;
  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [
    copyDesktopItems
    dpkg
    makeWrapper
  ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x "$src" .

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm444 \
      opt/apps/com.haimacloud.otohime/files/resources/app.asar \
      "$out/share/haimacloud/app.asar"

    install -Dm444 \
      opt/apps/com.haimacloud.otohime/entries/icons/hicolor/256x256/apps/haimacloud.png \
      "$out/share/icons/hicolor/256x256/apps/haimacloud.png"

    makeWrapper ${lib.getExe electron} "$out/bin/haimacloud" \
      --add-flags "$out/share/haimacloud/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set CHROME_DESKTOP "haimacloud.desktop"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "haimacloud";
      desktopName = "HaimaCloud";
      comment = "HaimaCloud cloud computer client";
      exec = "haimacloud %U";
      icon = "haimacloud";
      startupWMClass = "cloud-computer-client";
      categories = [ "Game" ];
      mimeTypes = [ "x-scheme-handler/hmydn" ];
      extraConfig = {
        "Name[zh_CN]" = "海马云电脑";
        "Comment[zh_CN]" = "海马云电脑桌面客户端";
      };
    })
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    test -x "$out/bin/haimacloud"
    test -f "$out/share/haimacloud/app.asar"
    test -f "$out/share/applications/haimacloud.desktop"
    test -f "$out/share/icons/hicolor/256x256/apps/haimacloud.png"

    runHook postInstallCheck
  '';

  meta = {
    description = "HaimaCloud cloud computer client";
    homepage = "https://pc.haimacloud.com/";
    license = lib.licenses.unfree;
    mainProgram = "haimacloud";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
