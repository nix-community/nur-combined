{
  lib,
  stdenv,
  pkgs,
  fetchurl,
  dpkg,
  buildFHSEnv,
  writeShellScript,
  glibcLocales,
}:

# 企业微信 (WeCom / WeChat Work) packaged via Spark Store bottle, run with
# nixpkgs Wine Wayland instead of deepin-wine10-stable.

let
  bottleVersion = "5.0.0.6008~spark2";
  version = "5.0.0.6008";
  packageVersionMarker = "${version}-nix-wine-wayland-1";
  wine = pkgs.wineWow64Packages.waylandFull;
  glibcLocaleArchiveEnv =
    "LOCALE_ARCHIVE_${lib.replaceStrings [ "." ] [ "_" ] (lib.versions.majorMinor stdenv.cc.libc.version)}";

  unpackDeb =
    {
      pname,
      version,
      src,
    }:
    stdenv.mkDerivation {
      inherit pname version src;
      nativeBuildInputs = [ dpkg ];
      unpackPhase = ''
        runHook preUnpack
        dpkg-deb -x $src .
        runHook postUnpack
      '';
      installPhase = ''
        runHook preInstall
        mkdir -p $out
        for d in opt usr; do
          [ -d "$d" ] && cp -r --no-preserve=ownership "$d" "$out/"
        done
        runHook postInstall
      '';
      dontStrip = true;
      dontPatchELF = true;
      dontFixup = true;
    };

  wxworkBottle = unpackDeb {
    pname = "wxwork-bottle";
    version = bottleVersion;
    src = fetchurl {
      url = "https://mirrors.sdu.edu.cn/spark-store-repository/store/chat/com.qq.weixin.work.deepin/com.qq.weixin.work.deepin_${bottleVersion}_amd64.deb";
      hash = "sha256-qBnLOEoGsov/nlRgrPH2Z2e+1QXxMj9nx8IsLclBC88=";
    };
  };

  wxworkLocales = glibcLocales.override {
    allLocales = false;
    locales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
  };

  launcher = writeShellScript "wxwork-launch" ''
    set -euo pipefail

    export ${glibcLocaleArchiveEnv}="${wxworkLocales}/lib/locale/locale-archive"
    export LOCALE_ARCHIVE_2_27="${wxworkLocales}/lib/locale/locale-archive"
    export LOCALE_ARCHIVE="${wxworkLocales}/lib/locale/locale-archive"
    export LANG="''${LANG:-zh_CN.UTF-8}"
    export LC_ALL="''${LC_ALL:-zh_CN.UTF-8}"
    export GTK_IM_MODULE="''${GTK_IM_MODULE:-fcitx}"
    export QT_IM_MODULE="''${QT_IM_MODULE:-fcitx}"
    export XMODIFIERS="''${XMODIFIERS:-@im=fcitx}"
    export WINEDLLOVERRIDES="mscoree,mshtml="

    appdir=/opt/apps/com.qq.weixin.work.deepin/files
    export WINEPREFIX="''${WXWORK_PREFIX:-$HOME/.deepinwine/Deepin-WXWork}"
    wine_cmd=wine

    fix_links() {
      mkdir -p "$WINEPREFIX/dosdevices" "$WINEPREFIX/drive_c/users/$USER"
      ln -sfn ../drive_c "$WINEPREFIX/dosdevices/c:"
      ln -sfn / "$WINEPREFIX/dosdevices/z:"
      ln -sfn "$HOME" "$WINEPREFIX/dosdevices/y:"
      ln -sfn "$HOME/Desktop" "$WINEPREFIX/drive_c/users/$USER/Desktop"
      ln -sfn "$HOME/Downloads" "$WINEPREFIX/drive_c/users/$USER/Downloads"
    }

    deploy_bottle() {
      mkdir -p "$WINEPREFIX"
      7z x "$appdir/files.7z" -o"$WINEPREFIX" -bso0 -bsp0 -bse2

      if [ -d "$WINEPREFIX/drive_c/users/@current_user@" ]; then
        rm -rf "$WINEPREFIX/drive_c/users/$USER"
        mv "$WINEPREFIX/drive_c/users/@current_user@" "$WINEPREFIX/drive_c/users/$USER"
      fi
      for reg in "$WINEPREFIX"/*.reg; do
        [ -e "$reg" ] && sed -i "s#@current_user@#$USER#g" "$reg"
      done
      find "$WINEPREFIX/drive_c/windows" -type l -lname '/opt/deepin-wine*' -delete

      fix_links
      echo "${packageVersionMarker}" > "$WINEPREFIX/PACKAGE_VERSION.nix-wayland"
    }

    if [ ! -f "$WINEPREFIX/PACKAGE_VERSION.nix-wayland" ] \
       || [ "$(cat "$WINEPREFIX/PACKAGE_VERSION.nix-wayland")" != "${packageVersionMarker}" ]; then
      rm -rf "$WINEPREFIX"
      deploy_bottle
    else
      fix_links
    fi

    # Prefer Wine's native Wayland driver, but keep x11 as a fallback so the
    # same prefix can still be tested under Xwayland by setting DISPLAY.
    "$wine_cmd" reg add 'HKCU\Software\Wine\Drivers' /v Graphics /t REG_SZ /d 'wayland,x11' /f >/dev/null
    "$wine_cmd" reg add 'HKCU\Control Panel\Desktop' /v LogPixels /t REG_DWORD /d 96 /f >/dev/null
    "$wine_cmd" reg add 'HKCU\Software\Wine\DllOverrides' /v winemenubuilder.exe /f >/dev/null

    if [ -n "''${WXWORK_PURE_WAYLAND:-}" ]; then
      unset DISPLAY
    fi

    cd "$WINEPREFIX/drive_c/Program Files (x86)/WXWork"
    exec "$wine_cmd" 'c:/Program Files (x86)/WXWork/WXWork.exe' "$@"
  '';

in
buildFHSEnv {
  pname = "wxwork";
  inherit version;

  targetPkgs =
    pkgs: with pkgs; [
      wine
      bash
      coreutils
      gnused
      gawk
      gnugrep
      findutils
      p7zip
      procps
      wqy_microhei
      wqy_zenhei
      noto-fonts-cjk-sans
      fontconfig
      freetype
      libGL
      mesa
      vulkan-loader
      libxkbcommon
      wayland
      wayland-protocols
      libdecor
      dbus
      glib
      gsettings-desktop-schemas
      gtk3
      alsa-lib
      alsa-plugins
      libpulseaudio
      cups
      libgphoto2
      pcsclite
      sane-backends
      libusb1
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-libav
    ];

  extraBuildCommands = ''
    mkdir -p "$out/opt/apps"
    cp -r --no-preserve=ownership \
      ${wxworkBottle}/opt/apps/com.qq.weixin.work.deepin \
      "$out/opt/apps/"
    chmod u+w "$out/opt/apps/com.qq.weixin.work.deepin/files"
    chmod -R u+w "$out/opt/apps/com.qq.weixin.work.deepin/files/dlls"
    rm -rf "$out/opt/apps/com.qq.weixin.work.deepin/files/dlls"

    mkdir -p "$out/usr/lib64/locale"
    ln -sfn ${wxworkLocales}/lib/locale/locale-archive "$out/usr/lib64/locale/locale-archive"
  '';

  runScript = launcher;

  extraInstallCommands = ''
    install -Dm644 \
      ${wxworkBottle}/opt/apps/com.qq.weixin.work.deepin/entries/applications/com.qq.weixin.work.deepin.desktop \
      $out/share/applications/wxwork.desktop
    substituteInPlace $out/share/applications/wxwork.desktop \
      --replace-fail '"/opt/apps/com.qq.weixin.work.deepin/files/run.sh" -f %f' 'wxwork %U' \
      --replace-fail 'Icon=com.qq.weixin.work.deepin' 'Icon=wxwork' \
      --replace-fail 'Name=WXWork' 'Name=WXWork' \
      --replace-fail 'Name[zh_CN]=企业微信' 'Name[zh_CN]=企业微信' \
      --replace-fail 'StartupWMClass=com.qq.weixin.work.deepin' 'StartupWMClass=WXWork.exe'
    install -Dm644 \
      ${wxworkBottle}/opt/apps/com.qq.weixin.work.deepin/entries/icons/hicolor/48x48/apps/com.qq.weixin.work.deepin.svg \
      $out/share/icons/hicolor/scalable/apps/wxwork.svg
  '';

  meta = {
    description = "Tencent WeCom launcher using nixpkgs Wine Wayland";
    homepage = "https://work.weixin.qq.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "wxwork";
  };
}
