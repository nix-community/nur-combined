{
  sources,
  version,
  pubspecLock,
  gitHashes,
  lib,
  flutter338,
  makeDesktopItem,
  copyDesktopItems,
  alsa-lib,
  mpv-unwrapped,
  libplacebo,
  libappindicator,
# libass,
# ffmpeg,
# libunwind,
# shaderc,
# vulkan-loader,
# lcms2,
# libdovi,
# libdvdnav,
# libdvdread,
# mujs,
# libbluray,
# lua,
# rubberband,
# libuchardet,
# zimg,
# openal,
# pipewire,
# libpulseaudio,
# libcaca,
# libdrm,
# libdisplay-info,
# libgbm,
# libxscrnsaver,
# libxpresent,
# nv-codec-headers-12,
# libva,
# libvdpau,
}:

let
  description = "Third-party Bilibili client developed in Flutter";
  majorMinorPatch = v: builtins.concatStringsSep "." (lib.take 3 (builtins.splitVersion v));
  srcInfo = lib.importJSON ./src-info.json;
in
flutter338.buildFlutterApplication {
  inherit (sources) pname src;
  inherit version pubspecLock gitHashes;

  nativeBuildInputs = [
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    mpv-unwrapped
    libplacebo
    libappindicator
    # libass
    # ffmpeg
    # libunwind
    # shaderc
    # vulkan-loader
    # lcms2
    # libdovi
    # libdvdnav
    # libdvdread
    # mujs
    # libbluray
    # lua
    # rubberband
    # libuchardet
    # zimg
    # openal
    # pipewire
    # libpulseaudio
    # libcaca
    # libdrm
    # libdisplay-info
    # libgbm
    # libxscrnsaver
    # libxpresent
    # nv-codec-headers-12
    # libva
    # libvdpau
  ];

  preBuild = ''
    cat <<EOL > lib/build_config.dart
    class BuildConfig {
      static const int versionCode = ${toString srcInfo.revCount};
      static const String versionName = '${majorMinorPatch version}-${
        builtins.substring 0 9 srcInfo.rev
      }';
      static const int buildTime = ${toString srcInfo.time};
      static const String commitHash = '${srcInfo.rev}';
    }
    EOL
  '';

  postInstall = ''
    declare -A sizes=(
      [mdpi]=128
      [hdpi]=192
      [xhdpi]=256
      [xxhdpi]=384
      [xxxhdpi]=512
    )
    for var in "''${!sizes[@]}"; do
      width=''${sizes[$var]}
      install -Dm644 "android/app/src/main/res/drawable-$var/splash.png" \
        "$out/share/icons/hicolor/''${width}x$width/apps/piliplus.png"
    done
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "piliplus";
      exec = "piliplus";
      icon = "piliplus";
      desktopName = "PiliPlus";
      categories = [
        "Video"
        "AudioVideo"
      ];
      comment = description;
      extraConfig = {
        "Comment[zh_CN]" = "使用 Flutter 开发的 BiliBili 第三方客户端";
        "Comment[zh_TW]" = "使用 Flutter 開發的 BiliBili 第三方客戶端";
      };
    })
  ];

  meta = {
    inherit description;
    homepage = "https://github.com/bggRGjQaUbCoE/PiliPlus";
    changelog = "https://github.com/bggRGjQaUbCoE/PiliPlus/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.linux;
    mainProgram = "piliplus";
  };
}
