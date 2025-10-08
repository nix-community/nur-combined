{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  # 基础依赖
  gtk3,
  pango,
  atk,
  cairo,
  gdk-pixbuf,
  # X11 相关
  xorg,
  # 网络和加密
  openssl,
  curl,
  nss,
  nspr,
  # 多媒体
  ffmpeg,
  # 其他系统库
  zlib,
  libuuid,
  libselinux,
  libsepol,
  libcap,
  systemd,
  # 桌面集成
  xdg-utils,
  ...
}:
stdenv.mkDerivation rec {
  pname = "baidunetdisk";
  version = "4.17.7";

  src = fetchurl {
    url = "https://pkg-ant.baidu.com/issue/netdisk/LinuxGuanjia/4.17.7/baidunetdisk_4.17.7_amd64.deb";
    sha256 = "0g9vcny72p3x74rrylqq22y845j8dm0k0ih3xxbkz896avq1iv2h";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    # GTK 相关
    gtk3
    pango
    atk
    cairo
    gdk-pixbuf

    # X11 相关
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXfixes
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXtst
    xorg.libXi
    xorg.libXScrnSaver
    xorg.libxcb
    xorg.xcbutil
    xorg.xcbutilcursor
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm

    # 网络和加密
    openssl
    curl
    nss
    nspr

    # 多媒体
    ffmpeg

    # 系统库
    zlib
    libuuid
    libselinux
    libsepol
    libcap
    systemd

    # 桌面集成
    xdg-utils
  ];

  runtimeDependencies = [
    "${xorg.xcbutilwm}/lib"
  ];

  # 确保自动修补ELF文件
  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall

    # 安装程序主体
    mkdir -p $out/opt
    cp -r opt/baidunetdisk $out/opt/

    # 处理桌面文件
    if [ -f usr/share/applications/baidunetdisk.desktop ]; then
      substituteInPlace usr/share/applications/baidunetdisk.desktop \
        --replace-fail '/opt/baidunetdisk/baidunetdisk' "$out/bin/baidunetdisk"
      install -Dm644 usr/share/applications/baidunetdisk.desktop \
        "$out/share/applications/baidunetdisk.desktop"
    fi

    # 安装图标
    if [ -f opt/baidunetdisk/icon.png ]; then
      install -Dm644 opt/baidunetdisk/icon.png \
        "$out/share/icons/hicolor/256x256/apps/baidunetdisk.png"
    fi

    # 创建二进制链接
    mkdir -p $out/bin
    ln -sf "$out/opt/baidunetdisk/baidunetdisk" "$out/bin/baidunetdisk"

    # 安装其他资源文件
    if [ -d usr/share ]; then
      cp -r usr/share/* $out/share/
    fi

    runHook postInstall
  '';

  # 手动修补特殊依赖
  preFixup = ''
    # 确保所有可执行文件都能找到依赖
    find $out/opt/baidunetdisk -type f -executable \
      -exec patchelf --set-rpath "$(patchelf --print-rpath {}):$out/opt/baidunetdisk" {} \;
  '';

  meta = with lib; {
    description = "百度网盘 Linux 客户端";
    homepage = "https://pan.baidu.com/";
    license = licenses.unfree;
    mainProgram = "baidunetdisk";
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
