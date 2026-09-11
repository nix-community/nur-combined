{
  fetchurl,
  stdenv,
  lib,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  atk,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libX11,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXrender,
  libXtst,
  libgbm,
  libglvnd,
  nspr,
  nss,
  pango,
  libdrm,
  libxkbcommon,
  libxcb,
  libxshmfence,
  wayland,
  udev,
  libnotify,
  libpulseaudio,
  libxscrnsaver,
  libsecret,
  libcxx,
  libgcrypt,
  libuuid,
  mesa,
  vulkan-loader,
  libva,
  pipewire,
  libappindicator-gtk3,
  systemd,
  libxkbfile,
}:
let
  version = "0.2.2";

  deps = [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libxscrnsaver
    libgbm
    libglvnd
    nspr
    nss
    pango
    libdrm
    libxkbcommon
    libxcb
    libxshmfence
    wayland
    udev
    libnotify
    libpulseaudio
    libsecret
    libcxx
    libgcrypt
    libuuid
    mesa
    vulkan-loader
    libva
    pipewire
    libappindicator-gtk3
    systemd
    libxkbfile
    stdenv.cc.cc.lib
  ];

  libPath = lib.makeLibraryPath deps;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "qoder-cn";
  inherit version;

  src = fetchurl {
    url = "https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/${version}/Qoder-CN-linux-amd64.deb";
    hash = "sha256-pBLz2nM8FIpZhwDFiYXH160v9cF7aTx7HEeLah8fQRg=";
  };

  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = deps;

  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
  ];

  unpackPhase = ''
    dpkg -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/lib/qoder-cn
    mkdir -p $out/share

    # deb 解包后的目录名含空格（"opt/Qoder CN"）
    cp -r "opt/Qoder CN"/* $out/lib/qoder-cn/

    # desktop 文件与图标
    cp -r usr/share/* $out/share/

    # 修正 desktop 文件中的 Exec 路径（原为 /opt/Qoder CN/...）
    substituteInPlace $out/share/applications/qoder-cn.desktop \
      --replace-fail '"/opt/Qoder CN/qoder-cn"' "$out/bin/qoder-cn"

    # Nix store 无法 setuid，chrome-sandbox 需要 0755 + user namespace
    chmod 0755 $out/lib/qoder-cn/chrome-sandbox || true

    # Wayland 会话下强制走原生 Wayland 而非 XWayland（参考 pkgs/chatgpt）。
    # WAYLAND_DISPLAY 判断写在内层 bash wrapper，运行时展开。
    # --password-store=gnome-libsecret: Electron 的 safeStorage API 需要密码存储后端来
    # 加解密登录凭证。Electron 通过 XDG_CURRENT_DESKTOP 猜测后端，但 niri 不在其列表中，
    # 导致每次启动都无法读取已存储的 token，表现为每次都需要重新登录。
    # 显式指定 gnome-libsecret 强制使用 Secret Service API（GNOME Keyring）。
    makeWrapper $out/lib/qoder-cn/qoder-cn $out/bin/qoder-cn \
      --prefix LD_LIBRARY_PATH : "${libPath}" \
      --add-flags "\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}" \
      --add-flags "--password-store=gnome-libsecret"

    runHook postInstall
  '';

  meta = {
    description = "Qoder CN - Agent workbench for human and AI software teams (Chinese version, Electron)";
    homepage = "https://qoder.com.cn";
    downloadPage = "https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/${version}/Qoder-CN-linux-amd64.deb";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "qoder-cn";
  };
})
