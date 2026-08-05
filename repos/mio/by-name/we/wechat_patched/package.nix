{
  lib,
  stdenv,
  wechat,
  dbus,
  pkg-config,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
}:

stdenv.mkDerivation {
  pname = "wechat-patched";
  version = wechat.version;

  src = ./.;

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    pkg-config
  ];

  buildInputs = [ dbus ];

  buildPhase = ''
    runHook preBuild
    $CC -shared -fPIC -O2 -Wall -Wextra \
      $(pkg-config --cflags dbus-1) \
      -o libwechat_appearance.so libwechat_appearance.c \
      $(pkg-config --libs dbus-1) -lpthread
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 libwechat_appearance.so $out/lib/libwechat_appearance.so

    # Wrap nixpkgs wechat (FHS) so LD_PRELOAD is set for the real binary.
    makeWrapper ${lib.getExe wechat} $out/bin/wechat \
      --prefix LD_PRELOAD : "$out/lib/libwechat_appearance.so"

    ln -s wechat $out/bin/wechat-patched

    install -Dm644 ${wechat.src}/wechat.png \
      $out/share/icons/hicolor/256x256/apps/wechat-patched.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "wechat-patched";
      desktopName = "WeChat (system appearance)";
      genericName = "WeChat";
      exec = "wechat %U";
      icon = "wechat-patched";
      categories = [
        "Network"
        "InstantMessaging"
      ];
      comment = "WeChat with LD_PRELOAD follow-system light/dark (xdg-desktop-portal)";
    })
  ];

  passthru = {
    inherit (wechat) src fhsenv;
  };

  meta = {
    description = "WeChat with LD_PRELOAD interceptor to follow system light/dark (portal)";
    homepage = "https://linux.weixin.qq.com/";
    license = lib.licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "wechat";
  };
}
