{
  lib,
  fetchFromGitHub,
  fetchurl,
  stdenv,
  autoPatchelfHook,
  flutter,
  yq-go,
  pkg-config,
  mpv,
  alsa-lib,
  gtk3,
  glib,
  libepoxy,
  sqlite,
  libunwind,
  libdovi,
  libdvdcss,
  makeDesktopItem,
  copyDesktopItems,
  bash,
  writeScriptBin,
  ...
}: let
  pname = "Fladder";
  version = "0.10.1";
  src = fetchFromGitHub {
    owner = "DonutWare";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-lmtEgBxCmEYcckhSAXhMPDzNQBluTyW0yjkt6Rr9byA=";
  };
  media_kit_hash = "sha256-wQ5HOztwfJRymo+GzgTgHcRS/rzJfZcvBul5teSf/h8=";
in
  flutter.buildFlutterApplication
  rec {
    inherit pname version src;
    passthru = {
      pubspecLock2Json = writeScriptBin "pubspec-lock-to-json" ''
        #!${lib.getExe bash}
        ${lib.getExe yq-go} -e -o=json . ${src}/pubspec.lock > $1
      '';
    };
    pubspecLock = lib.importJSON ./pubspec-lock.json;
    gitHashes = {
      media_kit = media_kit_hash;
      media_kit_libs_android_video = media_kit_hash;
      media_kit_libs_ios_video = media_kit_hash;
      media_kit_libs_linux = media_kit_hash;
      media_kit_libs_macos_video = media_kit_hash;
      media_kit_libs_video = media_kit_hash;
      media_kit_libs_windows_video = media_kit_hash;
      media_kit_video = media_kit_hash;
    };

    # 覆盖内置的 media_kit_libs_linux 包源构建器，使用 DonutWare 的 fork
    customSourceBuilders = {
      media_kit_libs_linux = {
        version,
        src,
        ...
      }:
      # 使用 NixOS 内置的构建器逻辑，但替换为 DonutWare 的源
      let
        # DonutWare fork 的源码（与 gitHashes 中的 commit 一致）
        donutware-src = fetchFromGitHub {
          owner = "DonutWare";
          repo = "media-kit";
          rev = "34bde583caa800bf2beb06ec6287c943eda24296";
          hash = "sha256-wQ5HOztwfJRymo+GzgTgHcRS/rzJfZcvBul5teSf/h8=";
        };
      in
        stdenv.mkDerivation {
          pname = "media_kit_libs_linux";
          inherit version;
          # 使用 DonutWare fork 的源码，并设置正确的子路径
          src = "${donutware-src}/libs/linux/media_kit_libs_linux";

          # 保持与原包源构建器相同的 passthru 属性
          passthru.packageRoot = ".";

          dontBuild = true;

          # 应用 NixOS 内置的补丁逻辑
          postPatch =
            lib.optionalString (lib.versionAtLeast version "1.2.1") ''
              sed -i '/if(MIMALLOC_USE_STATIC_LIBS)/,/unset(MIMALLOC_USE_STATIC_LIBS CACHE)/d' linux/CMakeLists.txt
            ''
            + lib.optionalString (lib.versionOlder version "1.2.1") ''
              awk -i inplace 'BEGIN {opened = 0}; /# --*[^$]*/ { print (opened ? "]===]" : "#[===["); opened = !opened }; {print $0}' linux/CMakeLists.txt
            '';

          installPhase = ''
            runHook preInstall
            cp -r . $out
            runHook postInstall
          '';
        };

      # 为 fvp 插件添加自定义构建器，预下载 mdk-sdk
      fvp = {
        version,
        src,
        ...
      }: let
        # 预下载 mdk-sdk Linux 版本
        mdk-sdk-linux = stdenv.mkDerivation rec {
          pname = "mdk-sdk-linux";
          version = "0.35.0";

          src = fetchurl {
            url = "https://github.com/wang-bin/mdk-sdk/releases/download/v${version}/${pname}-x64.tar.xz";
            sha256 = "044yw4iln4qq6zshmp3f5k08dq8rl6vsnh3xn5ldh04lh4sxm88r";
          };

          unpackPhase = ''
            tar -xf $src
          '';

          installPhase = ''
            mkdir -p $out
            cp -r . $out/
          '';
        };
      in
        stdenv.mkDerivation {
          pname = "fvp";
          inherit version src;
          inherit (src) passthru;

          dontBuild = true;

          postPatch = ''
            # 预创建 lib/src/version.h 文件，避免 CMake 尝试写入只读位置
            mkdir -p lib/src
            echo '#pragma once' > lib/src/version.h
            echo '#define FVP_VERSION "${version}"' >> lib/src/version.h

            # 修改 cmake/deps.cmake 禁用 file(WRITE) 调用
            if [ -f cmake/deps.cmake ]; then
              substituteInPlace cmake/deps.cmake \
                --replace 'file(WRITE ''${VERSION_HEADER_FILE}' '# file(WRITE ''${VERSION_HEADER_FILE}'
            fi

            # 禁用网络下载，使用预下载的 mdk-sdk
            if [ -f linux/CMakeLists.txt ]; then
              substituteInPlace linux/CMakeLists.txt \
                --replace 'fvp_setup_deps(''${CMAKE_CURRENT_LIST_DIR})' '# fvp_setup_deps disabled - using predownloaded mdk-sdk'

              # 创建 mdk-sdk 目录并复制文件
              mkdir -p linux/mdk-sdk-linux-x64
              cp -r ${mdk-sdk-linux}/* linux/
            fi
          '';

          installPhase = ''
            runHook preInstall
            cp -r . $out
            runHook postInstall
          '';
        };
    };

    # 添加必要的系统依赖
    nativeBuildInputs = [
      pkg-config
      autoPatchelfHook
      copyDesktopItems
    ];
    buildInputs =
      [
        mpv
        gtk3
        alsa-lib
        glib
        libepoxy
        sqlite
        libunwind
        libdovi
        libdvdcss
      ]
      ++ mpv.unwrapped.buildInputs;
    desktopItems = [
      (makeDesktopItem {
        name = pname;
        startupWMClass = "nl.jknaapen.fladder";
        comment = "A Simple Jellyfin Frontend built on top of Flutter.";
        exec = pname;
        icon = "fladder_icon_desktop";
        desktopName = pname;
        categories = [
          "Video"
          "TV"
        ];
        type = "Application";
        terminal = false;
      })
    ];

    postInstall = ''
      mkdir -p $out/bin $out/share/pixmaps
      cp ${src}/icons/production/fladder_icon_desktop.png $out/share/pixmaps/fladder_icon_desktop.png
    '';

    postPatch = ''
      # 修复 RepeatMode 命名冲突 - Flutter 3.41.2 添加了新的 RepeatMode，与 Fladder 的冲突
      # 将 Fladder 的 RepeatMode 使用前缀
      for file in lib/models/playback/direct_playback_model.dart lib/models/playback/transcode_playback_model.dart; do
        if [ -f "$file" ]; then
          # 将 RepeatMode 替换为 fpd.RepeatMode (假设使用 fully qualified prefix)
          sed -i 's/RepeatMode\./fpd.RepeatMode./g' "$file" 2>/dev/null || true
          # 在导入语句中添加 fpd 前缀
          sed -i '1i\import "package:fladder/jellyfin/jellyfin_open_api.enums.swagger.dart" as fpd;' "$file" 2>/dev/null || true
        fi
      done
    '';

    preferLocalBuild = true;
    meta = with lib; {
      description = "A Simple Jellyfin Frontend built on top of Flutter.";
      homepage = "https://github.com/DonutWare/Fladder";
      platforms = with platforms; (intersectLists x86 linux);
      license = with licenses; [gpl3Only];
      mainProgram = pname;
      sourceProvenance = with sourceTypes; [fromSource];
    };
  }
