# Packaaged by novel2430, original file is licensed under the MIT license.
# https://github.com/novel2430/MyNUR/blob/master/pkgs/wpsoffice-365/default.nix

# Install Scripts from AUR
#   - https://aur.archlinux.org/packages/wps-office-365
{
  lib,
  stdenv,
  makeWrapper,
  fetchFromGitHub,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  alsa-lib,
  at-spi2-core,
  libtool,
  libxkbcommon,
  nspr,
  mesa,
  libtiff,
  udev,
  gtk3,
  qtbase,
  xorg,
  cups,
  pango,
  freetype,
  libjpeg,
  libpulseaudio,
  fcitx5-qt,
  libbsd,
  libusb1,
  libmysqlclient,
  fontconfig,
  glib,
  libuuid,
  libglvnd,
  cairo,
  gdk-pixbuf,
  # For wpscloudsvr wrapper
  pkg-config,
  libappindicator-gtk3,
}:
stdenv.mkDerivation (final: {
  pname = "wpsoffice-365";
  version = "12.8.2.21176";

  src = fetchurl {
    url = "https://pubwps-wps365-obs.wpscdn.cn/download/Linux/${lib.last (builtins.splitVersion final.version)}/wps-office_${final.version}.AK.preload.sw_amd64.deb";
    hash = "sha256-kcxZ5ySWYpBJ7a8bNfp9ho4vWPZaVz2fcN+5HwQoGyw=";
    # curlOptsList = [ "-ehttps://365.wps.cn" ];
  };

  unpackCmd = " dpkg -x $src .";
  sourceRoot = ".";

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  preBuild = ''
    addAutoPatchelfSearchPath ${libmysqlclient}/lib/mariadb/
  '';

  buildInputs = [
    stdenv.cc.cc
    stdenv.cc.libc
    stdenv.cc.cc.lib
    alsa-lib
    at-spi2-core
    libtool
    libxkbcommon
    nspr
    mesa
    udev
    gtk3
    qtbase
    xorg.libXdamage
    xorg.libXtst
    xorg.libXv
    xorg.libXScrnSaver
    xorg.libxcb
    xorg.libX11
    xorg.libXrender
    xorg.libSM
    xorg.libICE
    xorg.libXcursor
    cups
    pango
    libpulseaudio
    libjpeg
    freetype
    fcitx5-qt
    libbsd
    libusb1
    libmysqlclient
    fontconfig
    glib
    libuuid
    libglvnd
    cairo
    gdk-pixbuf
    libtiff
    libappindicator-gtk3
  ];

  wpscloudsvr-wrapper = fetchFromGitHub {
    owner = "7Ji";
    repo = "wpscloudsvr-wrapper";
    rev = "3ce0834f6fb2b58cb8288d8190254f881f682094";
    sha256 = "sha256-LPpI4EboYUoLaod4gxDVty3VylPCN/ZexkE4KeCfla8=";
  };

  buildPhase = ''
    runHook preBuild

    # Build wpscloudsvr-wrapper
    gcc $(pkg-config --cflags gtk+-3.0 appindicator3-0.1) $(pkg-config --libs gtk+-3.0 appindicator3-0.1) -DSVR_PATH=\"$out/opt/kingsoft/wps-office/office6/wpscloudsvr\" -o ./wpscloudsvr ${final.wpscloudsvr-wrapper}/wpscloudsvr.c

    runHook postBuild
  '';

  dontWrapQtApps = true;

  autoPatchelfIgnoreMissingDeps = [
    "libpeony.so.3"
    "libcaja-extension.so.1"
  ];

  installPhase = ''
    ls .
    runHook preInstall
    prefix=$out/opt/kingsoft/wps-office
    mkdir -p $out/opt/kingsoft/wps-office
    cp -r opt/kingsoft/wps-office/office6 $out/opt/kingsoft/wps-office/office6
    cp -r usr/* $out

    # remove file
    rm $out/bin/{wps_uninstall.sh,wps_xterm} \
      $out/share/applications/wps-office-uninstall.desktop \
      $out/share/applications/xiezuo.desktop

    # use system lib
    rm $out/opt/kingsoft/wps-office/office6/lib{jpeg,stdc++}.so*

    # fix python2 call
    sed -i "s/python -c 'import sys, urllib; print urllib\.unquote(sys\.argv\[1\])'/\
      python -c 'import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))'/" $out/bin/wps

    # fix template path
    sed -i 's|URL=.*|URL=/opt/kingsoft/wps-office/office6/mui/zh_CN/templates/newfile.docx|' \
      $out/share/templates/wps-office-wps-template.desktop
    sed -i 's|URL=.*|URL=/opt/kingsoft/wps-office/office6/mui/zh_CN/templates/newfile.xlsx|' \
      $out/share/templates/wps-office-et-template.desktop
    sed -i 's|URL=.*|URL=/opt/kingsoft/wps-office/office6/mui/zh_CN/templates/newfile.pptx|' \
      $out/share/templates/wps-office-wpp-template.desktop

    # fix menu category
    sed -i 's|Categories=.*|&Office;|' $out/share/applications/*.desktop
    sed -i '$a Categories=Office;' $out/share/applications/wps-office-officeassistant.desktop

    # fix menu category
    sed -i 's|Categories=.*|&Office;|' $out/share/applications/*.desktop
    sed -i '$a Categories=Office;' $out/share/applications/wps-office-officeassistant.desktop

    # fix background process
    sed -i '2i [[ $(ps -ef | grep -c "office6/$(basename $0)") == 1 ]] && gOptExt=-multiply' $out/bin/{wps,wpp,et,wpspdf}

    # fix input method
    sed -i '2i [[ "$XMODIFIERS" == "@im=fcitx" ]] && export QT_IM_MODULE=fcitx' $out/bin/{wps,wpp,et,wpspdf}

    # fix xxx Njk0QkYtWVVEQkctRUFSNjktQlBSR0ItQVRRWEgK
    sed -i 's|YUA..=NsbhfV4nLv_oZGENyLSVZA..|YUA..=WHfH10HHgeQrW2N48LfXrA..|' \
      $out/opt/kingsoft/wps-office/office6/cfgs/oem.ini
    install -dm777 $out/opt/kingsoft/.auth/

    # Fix /bin path
    ## wps, wpp, et, wpspdf, misc, wpsclouddisk
    for i in wps wpp et wpspdf misc wpsclouddisk; do
      substituteInPlace $out/bin/$i \
        --replace-warn /opt/kingsoft/wps-office $prefix
    done
    ## quickstartoffice
    substituteInPlace $out/bin/quickstartoffice \
      --replace-warn /opt/kingsoft/wps-office $prefix
    substituteInPlace $out/bin/quickstartoffice \
      --replace-warn /usr/bin $out/bin
    ## wpsprint
    sed -i "2i export PATH=$out/bin:$PATH" $out/bin/wpsprint

    # Fix DesktopFile path
    for i in $out/share/applications/*;do
      substituteInPlace $i \
        --replace-warn /usr/bin $out/bin
    done

    # set ENV
    sed -i "2i unset WAYLAND_DISPLAY && export LD_LIBRARY_PATH=${lib.makeLibraryPath final.buildInputs} && export QT_QPA_PLATFORM=xcb" $out/bin/{wps,wpp,et,wpspdf,misc,wpsclouddisk}

    runHook postInstall
  '';

  preFixup = ''
    patchelf --replace-needed libmysqlclient.so.18 libmysqlclient.so $out/opt/kingsoft/wps-office/office6/libFontWatermark.so
  '';

  postInstall = ''
    # change wpscloudsvr
    mv $out/opt/kingsoft/wps-office/office6/wpscloudsvr $out/opt/kingsoft/wps-office/office6/wpscloudsvr.real
    install -DTm755 wpscloudsvr $out/opt/kingsoft/wps-office/office6/wpscloudsvr
  '';

  meta = {
    description = "WPS Office, is an office productivity suite. (Enable wpscloudsvr-wrapper)";
    homepage = "https://365.wps.cn";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfreeRedistributable;
  };
})
