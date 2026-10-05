################################################################################
# Mostly based on dingtalk-bin package from AUR:
# https://aur.archlinux.org/packages/dingtalk-bin
#
# 8.2 起 deb 自带全套 Qt5、OpenSSL 1.1、ICU 63、curl 等运行时库,
# 依赖清单只保留 deb 未自带、必须外部解析的库(依据 deb 内 ELF 的 DT_NEEDED)。
################################################################################
{ stdenv
, autoPatchelfHook
, makeWrapper
, patchelfUnstable
, lib
, fetchurl
, callPackage
, go
, # DingTalk dependencies
  alsa-lib
, at-spi2-atk
, at-spi2-core
, cairo
, cups
, dbus
, curl
, e2fsprogs
, expat
, file
, fontconfig
, freetype
, fribidi
, gdk-pixbuf
, glib
, gnutls
, graphite2
, gtk2
, gtk3
, harfbuzz
, krb5
, libdrm
, libgcrypt
, libepoxy
, libglvnd
, libinput
, libpulseaudio
, libxkbcommon
, libxcrypt-legacy
, mesa
, mtdev
, nspr
, nss
, openldap
, opus
, pango
, udev
, util-linux
, xorg
, sources
, ...
} @ args:
let
  libraries = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    curl
    dbus
    e2fsprogs
    expat
    fontconfig
    freetype
    fribidi
    gdk-pixbuf
    glib
    gnutls
    graphite2
    gtk2
    gtk3
    harfbuzz
    krb5
    libdrm
    libgcrypt
    libepoxy
    libglvnd
    libinput
    libpulseaudio
    libxkbcommon
    libxcrypt-legacy
    mesa
    mtdev
    nspr
    nss
    openldap
    opus
    pango
    udev
    util-linux
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXt
    xorg.libXtst
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXmu
    xorg.libXrandr
    xorg.libXrender
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
  ];
  arch = if stdenv.hostPlatform.isAarch64 then "arm64" else "amd64";
  dingtalk = sources."dingtalk-bin-${arch}";
in
stdenv.mkDerivation rec {
  pname = "dingtalk-bin";
  version = dingtalk.version;

  src = dingtalk.src;

  nativeBuildInputs = [ autoPatchelfHook makeWrapper patchelfUnstable file ];
  buildInputs = libraries;

  unpackPhase = ''
    ar x ${src}
    tar xf data.tar.xz

    mv opt/apps/com.alibabainc.dingtalk/files/version version
    mv opt/apps/com.alibabainc.dingtalk/files/*-Release.* release
    mv opt/apps/com.alibabainc.dingtalk/entries entries
    mv opt/apps/com.alibabainc.dingtalk/files/logo.ico logo.ico

    # Cleanup
    rm -f release/{*.a,*.la,*.prl}
    rm -f release/dingtalk_crash_report
    rm -f release/dingtalk_updater
    # doctor 链接了自带的 gtkglext(依赖 nixpkgs 已移除的 pangox),运行时用不到
    rm -f release/doctor
    # 自带的 gtk2 系列与 gbm 换成系统库(后者免去 wayland-server 依赖)
    rm -f release/libgdk*
    rm -f release/libgbm*
    # 自带 libcurl 链接 OpenLDAP 2.4 老版 sonames(nixpkgs 已无),换系统 curl
    rm -f release/libcurl.so.4
    rm -f release/libgtk*
    # 自带的 libm 是老 glibc 的副本,$ORIGIN 优先级会遮蔽系统 libm(缺 GLIBC_2.29+ 符号)
    rm -f release/libm.so.6
    rm -f release/libstdc++.so.6
    rm -f release/libstdc++*
    rm -rf release/Resources/{i18n/tool/*.exe,qss/mac}
  '';

  installPhase = ''
    mkdir -p $out
    mv version $out/

    # Move libraries
    # DingTalk relies on (some of) the exact libraries it ships with
    mv release $out/lib

    # 新版内核拒绝加载带 execstack 段的库(与 AUR 打包一致)
    ${patchelfUnstable}/bin/patchelf --clear-execstack $out/lib/dingtalk_dll.so $out/lib/libconference_new.so

    # Entrypoint
    # Entrypoint
    # 环境隔离:LD_LIBRARY_PATH 由 nix 全量接管(不含 glibc,否则 app spawn 的宿主
    # /bin/sh 等子进程会加载到 nix glibc 而崩溃),并剔除宿主注入的 LD_PRELOAD/LD_AUDIT。
    # app 自身 dlopen("libc.so.6") 的解析由 postFixup 写入的 RUNPATH 保证命中 nix glibc。
    mkdir -p $out/bin
    makeWrapper $out/lib/com.alibabainc.dingtalk $out/bin/dingtalk \
      --argv0 "com.alibabainc.dingtalk" \
      --set WAYLAND_DISPLAY "" \
      --set QT_QPA_PLATFORM xcb \
      --set QT_PLUGIN_PATH $out/lib \
      --unset LD_PRELOAD \
      --unset LD_AUDIT \
      --chdir "$out/lib" \
      --run 'i=$(printenv XMODIFIERS); case $i in *fcitx*) export QT_IM_MODULE=fcitx GTK_IM_MODULE=fcitx ;; *ibus*) export QT_IM_MODULE=ibus GTK_IM_MODULE=ibus IBUS_USE_PORTAL=1 ;; esac' \
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath libraries}"

    # App Menu
    mkdir -p $out/share/applications $out/share/pixmaps
    sed "s/Exec=.*/Exec=dingtalk %u/; s,Icon=.*,Icon=$out/share/pixmaps/dingtalk.ico," entries/applications/com.alibabainc.dingtalk.desktop > $out/share/applications/dingtalk.desktop
    cp logo.ico $out/share/pixmaps/dingtalk.ico
  '';

  # glibc 的 soname 查找(dlopen)顺序为 LD_LIBRARY_PATH → 调用方 RUNPATH →
  # /etc/ld.so.cache。部分自带库运行时 dlopen("libc.so.6") 但自身 DT_NEEDED 不含
  # glibc,在非 NixOS 宿主上会穿透到 /etc/ld.so.cache 并混入外部发行版的
  # glibc(进程内双 glibc,延迟崩溃),故须保证自带 ELF 的 RUNPATH 含 nix glibc。
  # autoPatchelfHook 把自身注册在 postFixupHooks(晚于 postFixup 变量执行),且其对
  # RPATH 的写入是整体覆盖;因此这里在 preFixup 中向 postFixupHooks 追加本修复,
  # 使其排在 autoPatchelf 之后执行。RUNPATH 不被子进程继承,不影响 popen 出的宿主命令。
  preFixup = ''
    addGlibcRunpath() {
      find "$out/lib" -type f | while read -r f; do
        case "$(file -b "$f")" in
          *ELF*) ${patchelfUnstable}/bin/patchelf --add-rpath "${stdenv.cc.libc}/lib" "$f" ;;
        esac
      done
    }
    postFixupHooks+=(addGlibcRunpath)
  '';

  meta = with lib; {
    description = "钉钉";
    homepage = "https://www.dingtalk.com/";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    license = licenses.unfreeRedistributable;
  };
}
