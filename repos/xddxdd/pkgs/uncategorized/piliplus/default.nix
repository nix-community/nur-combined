{
  sources,
  lib,
  flutter324,
  mpv,
  alsa-lib,
  copyDesktopItems,
  makeDesktopItem,
}:

flutter324.buildFlutterApplication rec {
  inherit (sources.piliplus) pname version src;

  nativeBuildInputs = [ copyDesktopItems ];

  buildInputs = [
    mpv
    alsa-lib
  ];

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  preBuild = ''
    cat <<EOL > lib/build_config.dart
    class BuildConfig {
      static const bool isDebug = false;
      static const String buildTime = '1980-01-01 00:00:00';
      static const String commitHash = '0000000000000000000000000000000000000000';
    }
    EOL
  '';

  gitHashes = {
    "auto_orientation" = "sha256-0QOEW8+0PpBIELmzilZ8+z7ozNRxKgI0BzuBS8c1Fng=";
    "canvas_danmaku" = "sha256-oVkgcQqDlNNno1VAReZCmXySv1rZbpHDSa0GLmBUmgM=";
    "chat_bottom_container" = "sha256-vCQuAaguOx9Li7txqepySPN6gzr15T7foc8rknHfuXE=";
    "extended_nested_scroll_view" = "sha256-5X8ghUlEO/lvz/3PmYuipCjcs+QrIciaH5wgWp9i+24=";
    "floating" = "sha256-d5G/xDoP7IOjTy3KXVJl5mk9/WRfcVdYV4YcQjez2Ic=";
    "share_plus" = "sha256-6vS4ZHugkBhHPVQCS2L02BU24PHMMS+VTsO/GS9mgbI=";
  };

  postInstall = ''
    install -Dm644 assets/images/logo/logo.png $out/share/pixmaps/piliplus.png
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "piliplus";
      exec = "piliplus";
      icon = "piliplus";
      desktopName = "PiliPlus";
      comment = "Third party Bilibili client built with Flutter";
      categories = [ "AudioVideo" ];
      extraConfig = {
        "Comment[zh_CN]" = "使用 Flutter 开发的 BiliBili 第三方客户端";
        "Comment[zh_TW]" = "使用 Flutter 開發的 BiliBili 第三方客戶端";
      };
    })
  ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Third party Bilibili client built with Flutter";
    homepage = "https://github.com/bggRGjQaUbCoE/PiliPlus";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "piliplus";
  };
}
