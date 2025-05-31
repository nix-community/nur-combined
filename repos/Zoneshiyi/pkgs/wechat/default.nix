{
  pkgs,
  lib,
  ...
}:
let
  pname = "wechat";
  version = "4.0.1.11";
  src = pkgs.fetchurl {
    url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
    hash = "sha256-OIyTbwvCFQg3E9FZFWD9Kvv3fyob01oMkUwIM6+fZoY=";
    executable = true;
  };
  wechat-runtime =
    (with pkgs.xorg; [
      libXcomposite
      libXrender
      libXrandr
      libXext
      libxcb
      libX11
      libXdamage
      libXfixes
      xcbutilwm
      xcbutilimage
      xcbutilkeysyms
      xcbutilrenderutil
    ])
    ++ (with pkgs; [
      glib.out
      libxkbcommon
      fontconfig
      dbus
      nss
      nspr
      at-spi2-core
      mesa
      alsa-lib
      libpulseaudio
      cairo
      freetype
      libdrm
      libGL
      libjack2
      zlib
      expat
      pango
    ]);
  wrap-librarys = [
    pkgs.libGL
  ];
in
pkgs.stdenvNoCC.mkDerivation rec{
  inherit pname version src;

  wechatLogo = pkgs.fetchurl {
    url = "https://worldvectorlogo.com/download/wechat-logo-1.svg";
    hash = "sha256-Itkhn9b2HHyCFyyIf/HpZsu+5w0SvFQRrqXqmON6MX8=";
  };

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    pkgs.makeBinaryWrapper
  ];
  buildInputs = wechat-runtime;

  phases = [
    "installPhase"
    "fixupPhase"
  ];

  installPhase = ''
    $src --appimage-extract
    mkdir -p $out
    mv ./squashfs-root/opt/wechat $out/
    mkdir -p $out/share/applications
    mv ./squashfs-root/wechat.desktop $out/share/applications
    sed -i "s|^Exec=AppRun|Exec=$out/bin/wechat|" $out/share/applications/wechat.desktop
    install -Dm444 $wechatLogo $out/share/icons/hicolor/scalable/apps/wechat-logo.svg
    mkdir -p $out/bin
    makeBinaryWrapper $out/wechat/wechat $out/bin/wechat \
    --suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath wrap-librarys}"
  '';

  meta = with lib; {
    description = "WeChat for Linux";
    homepage = "https://linux.weixin.qq.com";
    license = licenses.unfree;
    sourceProvenance = [
      sourceTypes.binaryNativeCode
    ];
    platforms = platforms.linux;
  };
}
