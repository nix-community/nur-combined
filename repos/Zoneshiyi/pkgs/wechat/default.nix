{
  pkgs,
  lib,
  ...
}:
let
  pname = "wechat";
  version = "4.0.1.11";
  src = pkgs.fetchurl {
    url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb";
    hash = "sha256-FkEODKeJXlqjdSgt5eSLLV/LlYsGPeay3P0CvtGQzAE=";
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
      libgbm
    ]);
in
pkgs.stdenvNoCC.mkDerivation rec {
  inherit pname version src;

  nativeBuildInputs = with pkgs; [
    dpkg
    makeBinaryWrapper
  ];
  buildInputs = wechat-runtime;

  phases = [
    "installPhase"
  ];

  installPhase = ''
    dpkg -x $src ./
    mkdir -p $out
    mv ./opt/wechat $out/
    mv ./usr/share $out/share
    substituteInPlace $out/share/applications/wechat.desktop \
      --replace-fail "/usr/bin/wechat" "$out/bin/wechat"
    sed -i "s|^Icon=.*$|Icon=wechat|" $out/share/applications/wechat.desktop
    mkdir -p $out/bin
    makeBinaryWrapper $out/wechat/wechat $out/bin/wechat \
    --suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath wechat-runtime}"
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
