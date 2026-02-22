{
  lib,
  stdenvNoCC,
  pkgs,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "wechat-latest";
  version = "20260214.152742";

  src = fetchurl {
    url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb";
    sha256 = "18h19n0d5jwxsqm4bsvsxgzf3wa8lmq4zhrdzb8mvkbl03my8ic4";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = with pkgs; [
    # 基础库
    glib
    zlib
    libgcc

    # X11 相关
    libx11
    libxext
    libxrender
    libxrandr
    libxinerama
    libxcursor
    libxfixes
    libxcomposite
    libxdamage
    libxtst
    libxi
    libxcb
    libxcb-util
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm

    # 网络、加密和认证
    nss
    nspr
    krb5

    # D-Bus
    dbus

    # 音频
    alsa-lib
    libjack2
    libpulseaudio

    # 图形相关
    libxkbcommon
    fontconfig

    # GTK 相关
    gtk3
    pango
    atk
    cairo
    gdk-pixbuf
    at-spi2-atk
    at-spi2-core

    # OpenGL/EGL
    mesa
    libdrm

    # 打印
    cups

    # 系统
    systemd
  ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt
    cp -r opt/* $out/opt/

    mkdir -p $out/bin
    ln -sf $out/opt/*/wechat $out/bin/wechat

    mkdir -p $out/share
    cp -r usr/share/* $out/share/

    # Fix .desktop file Exec path
    substituteInPlace $out/share/applications/wechat.desktop \
      --replace-fail "/usr/bin/wechat" "wechat"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Messaging and calling app";
    homepage = "https://www.wechat.com/en/";
    downloadPage = "https://linux.weixin.qq.com/en";
    license = licenses.unfree;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    mainProgram = "wechat";
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };

  passthru.updateScript = {
    command = [
      "bash"
      "${toString ./update.sh}"
    ];
    group = "we.wechat-latest";
  };
}
