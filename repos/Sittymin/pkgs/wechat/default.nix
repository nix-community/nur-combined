# NUR 自维护的微信 Linux 版。
#
# 来源：nixpkgs PR #560225（Moraxyc/wechat-update-script）的 deb 路线，
#   Linux 从 AppImage 切换到官方 deb，x86_64 4.1.13.9（hash 已验证可构建）。
# 与上游 PR 唯一的关键区别：Wayland。
#   自带 Qt 5.15.14 是静态编译，xcb 和 wayland 的 platform integration 都在
#   二进制里（strings 可见 QXcbIntegration 与 QWaylandIntegrationPlugin），
#   上游 PR 用 `--set QT_QPA_PLATFORM xcb` 硬锁 XWayland（理由是原生 Wayland
#   下输入法候选框定位不准）。这里故意不定 QT_QPA_PLATFORM，让 Qt 按
#   WAYLAND_DISPLAY 自动选择：Wayland 会话走原生 wayland，无则回落 xcb。
#   若遇到输入法/定位问题，随时可回退：QT_QPA_PLATFORM=xcb wechat
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,

  # native
  autoPatchelfHook,
  dpkg,
  makeShellWrapper,
  wrapGAppsHook3,

  # runtime
  alsa-lib,
  at-spi2-core,
  bzip2,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  glib,
  gtk3,
  libredirect,
  libice,
  libsm,
  libx11,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libglvnd,
  libjack2,
  libpulseaudio,
  libxcb,
  libxcb-keysyms,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  pipewire,
  systemd,
  util-linuxMinimal,
  wayland,
  xkeyboard-config,
  zlib,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "wechat";
  version = "4.1.13.9";

  src = fetchurl {
    # 上游实时直链，由 .github/workflows/update-wechat.yml 每天自动跟进
    # version/hash（同 chatgpt 包的机制）。直链内容会被官方原地替换，
    # 因此不要手锁 hash，交给 workflow 处理。
    url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb";
    hash = "sha256-CWhl4FC6DTwaI4hyJ+JAC/NDA3sdfWWMhMiP8mv9wX8=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeShellWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc) # for libatomic, libstdc++

    dbus
    glib
    systemd # for libudev

    at-spi2-core
    cairo
    fontconfig
    gtk3
    libxkbcommon
    xkeyboard-config
    pango

    libice
    libsm
    libx11
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxcb-keysyms

    wayland

    libglvnd
    mesa # for libgbm

    alsa-lib
    libjack2
    libpulseaudio
    pipewire

    cups

    nspr
    nss

    bzip2
    expat
    zlib
  ];

  runtimeDependencies = [
    alsa-lib
    gtk3
    libglvnd
    libpulseaudio
    libxcursor
    pipewire
    systemd
    wayland
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp -r opt "$out/"
    cp -r usr/share "$out/"

    substituteInPlace "$out/share/applications/wechat.desktop" \
      --replace-fail "/usr/bin/wechat" "wechat" \
      --replace-fail "/usr/share/icons/hicolor/256x256/apps/wechat.png" "wechat"

    runHook postInstall
  '';

  dontWrapGApps = true;

  preFixup = ''
    makeShellWrapper "$out/opt/wechat/wechat" "$out/bin/wechat" \
      "''${gappsWrapperArgs[@]}" \
      --set LD_PRELOAD "${libredirect}/lib/libredirect.so" \
      --set NIX_REDIRECTS "/usr/bin/lsblk=${lib.getExe' util-linuxMinimal "lsblk"}" \
      --set XKB_CONFIG_ROOT "${xkeyboard-config}/share/X11/xkb" \
      --set XLOCALEDIR "${libx11}/share/X11/locale" \
      --set-default QT_AUTO_SCREEN_SCALE_FACTOR "1" \
      --run '
        # Ensure WeChat storage path matches Tencent Docs lookup path
        if [ -d "$HOME/.xwechat/config" ]; then
          for cfg in "$HOME/.xwechat/config"/*.ini; do
            [ -f "$cfg" ] || continue
            if grep -q "^MyDocument:" "$cfg" && ! grep -q "^MyDocument:.local/share/wechat" "$cfg"; then
              sed -i "s|^MyDocument:.*|MyDocument:.local/share/wechat|" "$cfg"
            fi
          done
        fi

        if [ -z "''${QT_IM_MODULE:-}" ]; then
          case "''${XMODIFIERS:-}" in
            *fcitx*)
              export QT_IM_MODULE=fcitx
              ;;
            *ibus*)
              export QT_IM_MODULE=ibus
              export IBUS_USE_PORTAL=1
              ;;
          esac
        fi
      '
  '';

  postFixup = ''
    # ANGLE loads libGL.so.1 dynamically from the GPU process.
    patchelf --add-needed "${libglvnd}/lib/libGL.so.1" \
      "$out/opt/wechat/RadiumWMPF/runtime/WeChatAppEx"

    # WMPF and VLC both ship libffmpeg.so, but WMPF requires its own ABI.
    patchelf --replace-needed \
      libffmpeg.so \
      "$out/opt/wechat/RadiumWMPF/runtime/libffmpeg.so" \
      "$out/opt/wechat/RadiumWMPF/runtime/WeChatAppEx"
  '';

  meta = {
    description = "Messaging and calling app (NUR build, Wayland-first)";
    homepage = "https://www.wechat.com/en/";
    downloadPage = "https://linux.weixin.qq.com/en";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "wechat";
    maintainers = [ ];
  };
})
