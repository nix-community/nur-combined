{ stdenv
, lib
, buildFHSEnv
, dpkg
, autoPatchelfHook
, makeWrapper
, fetchurl
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, curl
, dbus
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk3
, libdrm
, libglvnd
, libnotify
, libpulseaudio
, libuuid
, libxkbcommon
, libxml2
, mesa
, nspr
, nss
, openssl
, pango
, systemd
, vulkan-loader
, xorg
, zlib
}:

let
  pname = "_115browser";
  version = "36.0.0";

  src = fetchurl {
    url = "https://down.115.com/client/115pc/lin/115br_v36.0.0.deb";
    sha256 = "sha256-E5+0421/SPHheTF+WtK9ixKHnnHTxP+Z2iaGVmG0/Eg=";
  };

  # 编译磁盘空间欺骗库
  fakeDiskSpace = stdenv.mkDerivation {
    name = "fake-disk-space";
    src = ./fake-disk-space.c;
    unpackPhase = "true";
    buildPhase = ''
      gcc -shared -fPIC -o libfakedisk.so $src -ldl
    '';
    installPhase = ''
      mkdir -p $out/lib
      cp libfakedisk.so $out/lib/
    '';
  };

  # 解包并安装 115 Browser
  unwrapped = stdenv.mkDerivation {
    pname = "${pname}-unwrapped";
    inherit version src;

    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      curl
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libglvnd
      libnotify
      libpulseaudio
      libuuid
      libxkbcommon
      libxml2
      mesa
      nspr
      nss
      openssl
      pango
      stdenv.cc.cc.lib
      systemd
      vulkan-loader
      xorg.libX11
      xorg.libxcb
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXScrnSaver
      xorg.libxshmfence
      xorg.libXtst
      zlib
    ];

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x $src .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt $out/bin $out/share

      # 复制应用文件
      cp -r usr/local/115Browser $out/opt/115browser

      # 复制桌面文件和图标
      cp -r usr/share/applications $out/share/

      # 修改桌面文件中的路径（暂时使用占位符，将在 FHS 包装时进一步修改）
      substituteInPlace $out/share/applications/115Browser.desktop \
        --replace-fail '/usr/local/115Browser/115.sh' 'EXEC_PLACEHOLDER' \
        --replace-fail '/usr/local/115Browser/res/115Browser.png' 'ICON_PLACEHOLDER'

      # 创建启动脚本
      makeWrapper $out/opt/115browser/115Browser $out/bin/115browser \
        --chdir $out/opt/115browser \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

      runHook postInstall
    '';

    meta = with lib; {
      description = "115浏览器 - 115 Browser";
      homepage = "https://www.115.com";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      maintainers = [ ];
    };
  };

in
# 使用 FHS 环境包装，以提供更好的兼容性
buildFHSEnv {
  name = pname;

  # 设置环境变量，确保应用能正确访问文件系统和检测磁盘空间
  profile = ''
    export HOME="''${HOME:-/home/$USER}"
    export XDG_DOWNLOAD_DIR="''${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
    export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
    export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
    # 使用 LD_PRELOAD 劫持磁盘空间检测系统调用
    export LD_PRELOAD="${fakeDiskSpace}/lib/libfakedisk.so''${LD_PRELOAD:+:$LD_PRELOAD}"
  '';

  targetPkgs = pkgs: (with pkgs; [
    unwrapped
    # 添加系统工具，帮助应用检测磁盘空间
    coreutils
    util-linux
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    curl
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libglvnd
    libnotify
    libpulseaudio
    libuuid
    libxkbcommon
    libxml2
    mesa
    nspr
    nss
    openssl
    pango
    stdenv.cc.cc.lib
    systemd
    vulkan-loader
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libxshmfence
    xorg.libXtst
    zlib
  ]);

  runScript = "${unwrapped}/bin/115browser";

  # 暴露 desktop 文件和图标
  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${unwrapped}/share/applications/115Browser.desktop $out/share/applications/

    # 替换占位符为实际的可执行文件和图标路径
    substituteInPlace $out/share/applications/115Browser.desktop \
      --replace-fail 'Exec=sh EXEC_PLACEHOLDER' "Exec=$out/bin/${pname}" \
      --replace-fail 'Icon=ICON_PLACEHOLDER' 'Icon=${unwrapped}/opt/115browser/res/115Browser.png'
  '';

  meta = unwrapped.meta // {
    mainProgram = pname;
  };
}
