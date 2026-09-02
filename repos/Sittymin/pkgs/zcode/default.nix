{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  copyDesktopItems,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libGL,
  libdrm,
  libxkbcommon,
  libxcb,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxscrnsaver,
  libxshmfence,
  libgbm,
  mesa,
  nspr,
  nss,
  pango,
  pciutils,
  pipewire,
  systemd,
  wayland,
  libnotify,
  libsecret,
  libuuid,
  libpulseaudio,
  libappindicator-gtk3,
  libcxx,
  libgcrypt,
  udev,
  libva,
  vulkan-loader,
  libXtst,
  libxkbfile,
  commandLineArgs ? "",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zcode";
  version = "3.8.1";

  src = fetchurl {
    url = "https://cdn-zcode.z.ai/zcode/electron/releases/${finalAttrs.version}/linux-x64/ZCode-${finalAttrs.version}-linux-x64.deb";
    hash = "sha256-WHGHdinrVvYIJRqV76kr+MKuBkXj1nrg3LXAISHkVXU=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    libdrm
    libxkbcommon
    libgbm
    mesa
    nspr
    nss
    pango
    pipewire
    systemd
    wayland
    libnotify
    libsecret
    libuuid
    libpulseaudio
    libappindicator-gtk3
    libcxx
    libgcrypt
    udev
    libva
    vulkan-loader
    stdenv.cc.cc.lib
    # X11 libs
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxscrnsaver
    libxshmfence
    libxcb
    libXtst
    libxkbfile
  ];

  runtimeDependencies = [
    systemd
    wayland
    libsecret
    udev
  ];

  # Some bundled libs like libffmpeg.so have weird RUNPATH and autoPatchelf
  # may complain. Ignore musl / swiftshader etc.
  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-*"
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # deb 包含 setuid chrome-sandbox，dpkg -x 会忽略权限，需要用 --fsys-tarfile
    dpkg --fsys-tarfile $src | tar --extract

    mkdir -p $out
    # opt/ZCode -> $out/opt/ZCode
    mkdir -p $out/opt
    cp -r opt/ZCode $out/opt/

    # usr/share -> $out/share (包含 desktop 和 icons )
    mkdir -p $out/share
    cp -r usr/share/* $out/share/

    # 修正 desktop 文件中的 Exec 路径
    substituteInPlace $out/share/applications/zcode.desktop \
      --replace-fail "/opt/ZCode/zcode" "$out/bin/zcode"

    # 确保 chrome-sandbox 权限正确（Nix store 无法 setuid，使用 0755 依赖 user namespace）
    chmod 0755 $out/opt/ZCode/chrome-sandbox || true

    # 包装主程序，使用 wrapGAppsHook 提供的 gappsWrapperArgs + 手动 LD_LIBRARY_PATH
    mkdir -p $out/bin
    makeWrapper $out/opt/ZCode/zcode $out/bin/zcode \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}:$out/opt/ZCode" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      ${lib.optionalString (commandLineArgs != "") "--add-flags ${lib.escapeShellArg commandLineArgs}"}

    runHook postInstall
  '';

  # wrapGAppsHook 需要的依赖已在 nativeBuildInputs，preFixup 会自动处理
  # 但需要补充 library path 给插件可能调用的二进制
  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}:$out/opt/ZCode"
      --prefix PATH : "${lib.makeBinPath [ glib ]}"
    )
  '';

  meta = {
    description = "ZCode - AI-powered coding agent desktop app (Electron)";
    homepage = "https://zcode.z.ai";
    downloadPage = "https://cdn-zcode.z.ai/zcode/electron/releases/${finalAttrs.version}/linux-x64/ZCode-${finalAttrs.version}-linux-x64.deb";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "zcode";
    maintainers = [ ];
  };
})
