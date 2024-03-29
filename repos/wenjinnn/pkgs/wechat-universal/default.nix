{ stdenvNoCC
, stdenv
, lib
, fetchurl
, dpkg
, nss
, nspr
, xorg
, pango
, zlib
, atkmm
, libdrm
, libxkbcommon
, xcbutilwm
, xcbutilimage
, xcbutilkeysyms
, xcbutilrenderutil
, mesa
, alsa-lib
, wayland
, openssl_1_1
, atk
, qt6
, at-spi2-atk
, at-spi2-core
, dbus
, cups
, gtk3
, libxml2
, cairo
, freetype
, fontconfig
, vulkan-loader
, gdk-pixbuf
, libexif
, ffmpeg
, pulseaudio
, systemd
, libuuid
, expat
, bzip2
, glib
, libva
, libGL
, libnotify
, buildFHSEnv
, writeShellScript
}:
let
  uosLicense = stdenv.mkDerivation {
    pname = "wechat-universal-license";
    version = "0.0.1";
    src = ./license.tar.gz;

    installPhase = ''
      mkdir -p $out
      cp -r etc var $out/
    '';
  };
  wechat-universal-env = stdenvNoCC.mkDerivation {
    meta.priority = 1;
    name = "wechat-universal-env";
    buildCommand = ''
      mkdir -p $out/etc
      mkdir -p $out/lib/license
      mkdir -p $out/usr/bin
      mkdir -p $out/usr/share
      mkdir -p $out/opt
      mkdir -p $out/var

      ln -s ${wechat}/opt/* $out/opt/
      ln -s ${wechat}/usr/lib/wechat-universal/license/etc/os-release  $out/etc/os-release
      ln -s ${wechat}/usr/lib/wechat-universal/license/etc/lsb-release  $out/etc/lsb-release
      ln -s ${wechat}/usr/lib/wechat-universal/license/var/*  $out/var/
      ln -s ${wechat}/usr/lib/wechat-universal/license/libuosdevicea.so $out/lib/license/
    '';
    preferLocalBuild = true;
  };

  wechat-universal-runtime = with xorg; [
    stdenv.cc.cc
    stdenv.cc.libc
    pango
    zlib
    xcbutilwm
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    libX11
    libXt
    libXext
    libSM
    libICE
    libxcb
    libxkbcommon
    libxshmfence
    libXi
    libXft
    libXcursor
    libXfixes
    libXScrnSaver
    libXcomposite
    libXdamage
    libXtst
    libXrandr
    libnotify
    atk
    atkmm
    cairo
    at-spi2-atk
    at-spi2-core
    alsa-lib
    dbus
    cups
    gtk3
    gdk-pixbuf
    libexif
    ffmpeg
    libva
    freetype
    fontconfig
    libXrender
    libuuid
    expat
    glib
    nss
    nspr
    libGL
    libxml2
    pango
    libdrm
    mesa
    vulkan-loader
    systemd
    wayland
    pulseaudio
    qt6.qt5compat
    openssl_1_1
    bzip2
  ];

  wechat = stdenvNoCC.mkDerivation
    rec {
      pname = "wechat-universal";
      version = "1.0.0.238";

      src = {
        x86_64-linux = fetchurl {
          url = "https://pro-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.wechat/com.tencent.wechat_${version}_amd64.deb";
          hash = "sha256-NxAmZ526JaAzAjtAd9xScFnZBuwD6i2wX2/AEqtAyWs=";
        };
        aarch64-linux = fetchurl {
          url = "https://pro-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.wechat/com.tencent.wechat_${version}_arm64.deb";
          hash = "sha256-3ru6KyBYXiuAlZuWhyyvtQCWbOJhGYzker3FS0788RE=";
        };
        loongarch64-linux = fetchurl {
          url = "https://pro-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.wechat/com.tencent.wechat_${version}_loongarch64.deb";
          hash = "sha256-iuJeLMKD6v8J8iKw3+cyODN7PZQrLpi9p0//mkI0ujE=";
        };
      }.${stdenv.system} or (throw "${pname}-${version}: ${stdenv.system} is unsupported.");

      # Don't blame about this. WeChat requires some binary from here to work properly
      uosSrc = {
        x86_64-linux = fetchurl {
          url = "https://pro-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.weixin/com.tencent.weixin_2.1.5_amd64.deb";
          hash = "sha256-vVN7w+oPXNTMJ/g1Rpw/AVLIytMXI+gLieNuddyyIYE=";
        };
        aarch64-linux = fetchurl {
          url = "https://pro-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.weixin/com.tencent.weixin_2.1.5_arm64.deb";
          hash = "sha256-XvGFPYJlsYPqRyDycrBGzQdXn/5Da1AJP5LgRVY1pzI=";
        };
        loongarch64-linux = fetchurl {
          url = "https://pro-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.weixin/com.tencent.weixin_2.1.5_loongarch64.deb";
          hash = "sha256-oa6rLE6QXMCPlbebto9Tv7xT3fFqYIlXL6WHpB2U35s=";
        };
      }.${stdenv.system} or (throw "${pname}-${version}: ${stdenv.system} is unsupported.");

      inherit uosLicense;

      nativeBuildInputs = [ dpkg ];

      unpackPhase = ''
        runHook preUnpack

        dpkg -x $src ./wechat-universal
        dpkg -x $uosSrc ./wechat-universal-old-source

        cp -r $uosLicense ./wechat-universal/license

        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out

        cp -r wechat-universal/* $out

        mkdir -pv $out/usr/lib/wechat-universal/license
        cp -r wechat-universal/license/** $out/usr/lib/wechat-universal/license
        cp -r wechat-universal-old-source/usr/lib/license/libuosdevicea.so $out/usr/lib/wechat-universal/license/

        runHook postInstall
      '';

      meta = with lib; {
        description = "Wechat universal version for linux";
        homepage = "https://weixin.qq.com/";
        license = licenses.unfree;
        platforms = [ "x86_64-linux" "aarch64-linux" "loongarch64-linux" ];
        sourceProvenance = with sourceTypes; [ binaryNativeCode ];
        maintainers = with maintainers; [ pokon548 ];
        mainProgram = "wechat-universal";
      };
    };
in
buildFHSEnv {
  inherit (wechat) name meta;
  runScript = writeShellScript "wechat-universal-launcher" ''
    export QT_QPA_PLATFORM=xcb
    export LD_LIBRARY_PATH=${lib.makeLibraryPath wechat-universal-runtime}
    ${wechat.outPath}/opt/apps/com.tencent.wechat/files/wechat
  '';
  extraInstallCommands = ''
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons
    cp -r ${wechat.outPath}/opt/apps/com.tencent.wechat/entries/applications/com.tencent.wechat.desktop $out/share/applications
    cp -r ${wechat.outPath}/opt/apps/com.tencent.wechat/entries/icons/* $out/share/icons/

    mv $out/bin/$name $out/bin/wechat-universal

    substituteInPlace $out/share/applications/com.tencent.wechat.desktop \
      --replace 'Exec=/usr/bin/wechat' "Exec=$out/bin/wechat-universal --"
  '';
  targetPkgs = pkgs: [ wechat-universal-env ];

  extraOutputsToInstall = [ "usr" "var/lib/uos" "var/uos" "etc" ];
}
