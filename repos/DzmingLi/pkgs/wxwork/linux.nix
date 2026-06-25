{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  buildFHSEnv,
  writeShellScript,
  glibcLocales,
}:

# 企业微信 (WeCom / WeChat Work) packaged via Spark Store 的 deepin-wine10 bottle。
# 拼装三个上游 deb：
#   1. com.qq.weixin.work.deepin (spark-store)  — WeCom 的 wine 容器，含 files.7z
#   2. deepin-wine10-stable (uniontech app-store) — WoW64 wine 二进制
#   3. spark-dwine-helper (spark-store)        — bash 启动脚手架 spark_run_v4.sh
# 三者一起塞进 buildFHSEnv，重现 deepin/spark 期望的 /opt 布局。
# 容器 (~/.deepinwine/Deepin-WXWork) 在首次运行时由 spark_run_v4.sh 把 files.7z 解出。

let
  bottleVersion = "5.0.0.6008~spark2";
  wineVersion = "10.14deepin8";
  helperVersion = "5.10.14-5.3.15";
  version = "5.0.0.6008";

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
      # Bottle contents are Windows PE + bash; nothing to strip / patchelf.
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

  deepinWine10 = unpackDeb {
    pname = "deepin-wine10-stable";
    version = wineVersion;
    src = fetchurl {
      url = "https://pro-store-packages.uniontech.com/appstore/pool/eagle-pro/d/deepin-wine10-stable/deepin-wine10-stable_${wineVersion}_amd64.deb";
      hash = "sha256-+hEZ8gUONSczRZCfhOxyCR1WVjPd3puujz3ZMLfPgCE=";
      # CDN 403s without a uniontech Referer.
      curlOptsList = [
        "--referer"
        "https://pro-store-packages.uniontech.com/"
      ];
    };
  };

  # Locale archive containing zh_CN.UTF-8. buildFHSEnv force-ships the default
  # glibcLocales (C + en_US) in baseTargetPaths; we replace the locale-archive
  # symlink with this one in extraBuildCommands.
  wxworkLocales = glibcLocales.override {
    allLocales = false;
    locales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
  };

  sparkDwineHelper = unpackDeb {
    pname = "spark-dwine-helper";
    version = helperVersion;
    src = fetchurl {
      url = "https://mirrors.sdu.edu.cn/spark-store-repository/store/tools/spark-dwine-helper/spark-dwine-helper_${helperVersion}_all.deb";
      hash = "sha256-bmj0Ca2OKdfGVjMVYqRFntXHlnZ51lsWW0zsLbx12gg=";
    };
  };

  launcher = writeShellScript "wxwork-launch" ''
    set -u
    # buildFHSEnv injects the default glibcLocales (C + en_US only) and exports
    # LOCALE_ARCHIVE_2_27 pointing at *that* archive. nixpkgs' glibc reads the
    # version-suffixed LOCALE_ARCHIVE_2_27 in preference to LOCALE_ARCHIVE and
    # ignores the latter once the former is set — so exporting only
    # LOCALE_ARCHIVE leaves glibc on the C+en_US archive and setlocale rejects
    # zh_CN.UTF-8. That silently breaks fcitx: wine's winex11 IME init calls
    # setlocale()/XSupportsLocale(), and when the locale is unsupported it
    # disables XIM entirely, so XMODIFIERS=@im=fcitx never takes effect. Point
    # *both* names at the wxworkLocales archive that includes zh_CN.
    export LOCALE_ARCHIVE_2_27="${wxworkLocales}/lib/locale/locale-archive"
    export LOCALE_ARCHIVE="$LOCALE_ARCHIVE_2_27"
    export LANG="''${LANG:-zh_CN.UTF-8}"
    export LC_ALL="''${LC_ALL:-zh_CN.UTF-8}"
    # IME plumbing — let callers override if they don't use fcitx
    export GTK_IM_MODULE="''${GTK_IM_MODULE:-fcitx}"
    export QT_IM_MODULE="''${QT_IM_MODULE:-fcitx}"
    export XMODIFIERS="''${XMODIFIERS:-@im=fcitx}"
    # Make sure deepin-wine10-stable is on PATH for spark_run_v4.sh
    export PATH="/opt/deepin-wine10-stable/bin:$PATH"
    # spark_kill.sh in spark-dwine-helper detects stale bottle processes by
    # reading /proc/<pid>/maps and /proc/<pid>/environ, both of which NixOS
    # denies for non-self pids (hidepid). When WeCom is force-logged-out by a
    # phone login it leaves WXWork.exe stuck on a modal, spark_kill.sh
    # silently fails to clean it up, and the next launch attaches to the dead
    # wineserver and never paints. pkill by cmdline as a fallback — that
    # /proc node IS readable for our own pids. Patterns match what actually
    # shows up in argv (the WINEPREFIX path lives only in environ).
    for pat in \
      'spark_run_v4\.sh Deepin-WXWork' \
      'WXWork\.exe' 'WXWorkWeb\.exe' 'WeMail\.exe' 'FlutterPlugins\.exe' \
      'winedevice\.exe' 'crashpad_handler\.exe' \
      'deepin-wine10-stable.* c:/Program Files .x86./WXWork' \
      'opt/deepin-wine10-stable/.*/wineserver' ; do
      pkill -KILL -u "$(id -u)" -f "$pat" 2>/dev/null || true
    done
    sleep 0.5
    exec /opt/apps/com.qq.weixin.work.deepin/files/run.sh "$@"
  '';

in
buildFHSEnv {
  pname = "wxwork";
  inherit version;

  # deepin-wine10 ships as a WoW64 build (no i386-unix loader), so we don't
  # need pkgsi686Linux.
  targetPkgs =
    pkgs: with pkgs; [
      # spark_run_v4.sh + transhell + log-function bash plumbing
      bash
      coreutils
      gnused
      gawk
      gnugrep
      findutils
      which
      file
      util-linux
      procps
      shadow
      # spark-dwine-helper hard deps
      zenity
      p7zip
      wmctrl
      (python3.withPackages (ps: [ ps.dbus-python ]))
      cabextract
      # CJK
      wqy_microhei
      wqy_zenhei
      noto-fonts-cjk-sans
      # NB: buildFHSEnv unconditionally injects the default `glibcLocales`
      # (which only ships C + en_US) into baseTargetPaths *before* any user
      # `targetPkgs` entry, so adding a custom .override here would lose the
      # priority fight. Instead we swap the symlink in extraBuildCommands
      # using `wxworkLocales` below.
      # GTK runtime so zenity dialogs render
      glib
      gsettings-desktop-schemas
      gtk3
      # Audio
      alsa-lib
      alsa-plugins
      libpulseaudio
      # System / wine native .so deps
      dbus
      systemd
      libgphoto2
      pcsclite
      libpng
      sane-backends
      libusb1
      ocl-icd
      ncurses
      # Crypto / net
      gnutls
      krb5
      openssl
      libgcrypt
      libxml2
      libxslt
      # Imaging
      fontconfig
      freetype
      libjpeg
      # X11
      libx11
      libxext
      libxcomposite
      libxcursor
      libxdamage
      libxi
      libxrandr
      libxrender
      libxxf86vm
      libxinerama
      libxfixes
      libxtst
      libxcb
      libxshmfence
      xdpyinfo
      xprop
      xkeyboard_config
      # OpenGL / Vulkan
      libGL
      mesa
      libdrm
      vulkan-loader
      # GStreamer (winegstreamer.so)
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-libav
      # zlib for misc tools
      zlib
    ];

  # NB: this script runs without `cd $out` — buildFHSEnv only `cd $out`s inside
  # build-fhsenv-chroot, but the bubblewrap variant uses runCommand which does
  # not. Use absolute $out paths.
  extraBuildCommands = ''
    mkdir -p "$out/opt/apps" "$out/opt/deepinwine/tools" "$out/usr/bin"

    cp -r --no-preserve=ownership \
      ${wxworkBottle}/opt/apps/com.qq.weixin.work.deepin \
      "$out/opt/apps/"
    cp -r --no-preserve=ownership \
      ${deepinWine10}/opt/deepin-wine10-stable \
      "$out/opt/"
    cp -r --no-preserve=ownership \
      ${sparkDwineHelper}/opt/spark-dwine-helper \
      "$out/opt/"

    # Re-create the symlinks that spark-dwine-helper's postinst would normally
    # place under /opt/deepinwine/tools/.
    ln -sf /opt/spark-dwine-helper/spark_run_v4.sh "$out/opt/deepinwine/tools/spark_run_v4.sh"
    ln -sf /opt/spark-dwine-helper/spark_kill.sh   "$out/opt/deepinwine/tools/spark_kill.sh"
    ln -sf /opt/spark-dwine-helper/spark_run_v4.sh "$out/opt/deepinwine/tools/run_v4.sh"

    # Replicate /usr/bin/deepin-wine10-stable shim so spark_run_v4.sh can
    # exec it via PATH lookup of $APPRUN_CMD.
    install -m755 ${deepinWine10}/usr/bin/deepin-wine10-stable "$out/usr/bin/deepin-wine10-stable"

    # spark_run_v4.sh's get_app_name() grep's /usr/share/applications/$DEB_PACKAGE_NAME.desktop
    # to look up the localized Name=. Provide it inside the chroot.
    mkdir -p "$out/usr/share/applications"
    install -m644 \
      ${wxworkBottle}/opt/apps/com.qq.weixin.work.deepin/entries/applications/com.qq.weixin.work.deepin.desktop \
      "$out/usr/share/applications/com.qq.weixin.work.deepin.desktop"

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
      --replace-fail 'StartupWMClass=com.qq.weixin.work.deepin' 'StartupWMClass=com.qq.weixin.work.deepin'
    install -Dm644 \
      ${wxworkBottle}/opt/apps/com.qq.weixin.work.deepin/entries/icons/hicolor/48x48/apps/com.qq.weixin.work.deepin.svg \
      $out/share/icons/hicolor/scalable/apps/wxwork.svg
  '';

  meta = {
    description = "Tencent WeCom / 企业微信 wrapped via deepin-wine10 (spark-store bottle)";
    homepage = "https://work.weixin.qq.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "wxwork";
  };
}
