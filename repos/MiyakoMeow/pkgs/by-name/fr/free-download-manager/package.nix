{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  openssl,
  xdg-utils,
  ffmpeg,
  libtorrent,
  gst_all_1,
  xorg,
  libxcrypt,
  unixODBC,
  postgresql,
  mysql80,
  # 额外依赖
  gtk3,
  pango,
  atk,
  cairo,
  gdk-pixbuf,
  ...
}:
stdenv.mkDerivation rec {
  pname = "free-download-manager";
  version = "6.29.0.6379";

  src = fetchurl {
    url = "http://debrepo.freedownloadmanager.org/pool/main/f/freedownloadmanager/freedownloadmanager_${version}_amd64.deb";
    sha256 = "sha256-WfB5JDO2DOZOQKWv+Ew+HYyQL2WbYhkR64oemufXvKU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    openssl
    xdg-utils
    ffmpeg
    libtorrent
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer

    # 新增XCB依赖
    xorg.libxcb
    xorg.xcbutil
    xorg.xcbutilcursor
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm # 新增包含libxcb-icccm.so.4的包

    # 数据库驱动依赖
    unixODBC
    postgresql.lib
    mysql80.client
    libxcrypt

    # 额外修复依赖
    gtk3 # Provides libgtk-3, libgdk-3
    pango # Provides libpangocairo-1.0, libpango-1.0
    atk # Provides libatk-1.0
    cairo # Provides libcairo-gobject, libcairo
    gdk-pixbuf # Provides libgdk_pixbuf-2.0
  ];

  runtimeDependencies = [
    "${gst_all_1.gst-plugins-base}/lib"
    "${gst_all_1.gstreamer}/lib"
    # 确保XCB库能被自动发现
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

    # 处理桌面文件
    substituteInPlace usr/share/applications/freedownloadmanager.desktop \
      --replace-fail '/opt/freedownloadmanager/icon.png' 'freedownloadmanager' \
      --replace-fail '/opt/freedownloadmanager/fdm' "$out/bin/fdm"
    sed -i '/^Exec=/i StartupWMClass=fdm' usr/share/applications/freedownloadmanager.desktop

    # 安装程序主体到/opt
    mkdir -p $out/opt
    cp -r opt/freedownloadmanager $out/opt/

    # 安装图标（明确指定目标文件名）
    install -Dm644 opt/freedownloadmanager/icon.png \
      "$out/share/icons/hicolor/256x256/apps/freedownloadmanager.png"

    # 安装桌面文件（确保目标路径包含文件名）
    install -Dm644 usr/share/applications/freedownloadmanager.desktop \
      "$out/share/applications/freedownloadmanager.desktop"

    # 创建二进制链接
    mkdir -p $out/bin
    ln -sf "$out/opt/freedownloadmanager/fdm" "$out/bin/fdm"

    runHook postInstall
  '';

  # 手动修补特殊依赖
  preFixup = ''
    # 排除无法满足的MimerSQL依赖
    patchelf --remove-needed libmimerapi.so $out/opt/freedownloadmanager/plugins/sqldrivers/libqsqlmimer.so

    # 指定ODBC库路径
    patchelf --add-needed libodbc.so.2 $out/opt/freedownloadmanager/plugins/sqldrivers/libqsqlodbc.so

    # 手动添加XCB ICCCM依赖路径
    find $out/opt/freedownloadmanager -type f -executable \
      -exec patchelf --add-needed libxcb-icccm.so.4 {} \;
  '';

  meta = with lib; {
    description = "FDM is a powerful modern download accelerator and organizer.";
    homepage = "https://www.freedownloadmanager.org/";
    license = licenses.unfree;
    mainProgram = "fdm";
    platforms = [ "x86_64-linux" ];
    maintainers = [ ]; # 替换为维护者信息
  };

  passthru.updateScript = {
    group = "fr.free-download-manager";
    command = [
      "nix-shell"
      "-p"
      "python3"
      "python3Packages.requests"
      "python3Packages.beautifulsoup4"
      "nix-update"
      "git"
      "--run"
      "bash -lc 'latest_version=$(python3 pkgs/by-name/fr/free-download-manager/update_version.py) && echo Latest version found: $latest_version && nix-update free-download-manager --version $latest_version'"
    ];
  };
}
