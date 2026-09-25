{
  lib,
  fetchurl,
  stdenvNoCC,

  # nativeBuildInputs
  autoPatchelfHook,
  unzip,

  # buildInputs
  alsa-lib,
  cups,
  dbus,
  fontconfig,
  freetype,
  glib,
  gst_all_1,
  krb5,
  libgcc,
  libGL,
  libpulseaudio,
  libx11,
  libxcb,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  libxext,
  libxkbcommon,
  zlib,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "melgeekhive";
  version = "1.6.5";

  src = fetchurl {
    url = "https://pancdn.melgeek.cn/software/hive/MelGeekHive-Linux-V${finalAttrs.version}.zip";
    curlOptsList = [
      "--user-agent"
      "Mozilla/5.0"
      "--referer"
      "https://www.melgeek.cn/download"
    ];
    hash = "sha256-f1ztuzfMQZutAns5VJ+l9OazURG8duwOGXBMPCfn30g=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    # libasound.so.2
    alsa-lib
    # libcups.so.2
    cups
    # libdbus-1.so.3
    dbus
    # libfontconfig.so.1
    fontconfig
    # libfreetype.so.6
    freetype
    # libglib-2.0.so.0
    # libgobject-2.0.so.0
    # libgthread-2.0.so.0
    glib
    # libgstallocators-1.0.so.0
    # libgstapp-1.0.so.0
    # libgstaudio-1.0.so.0
    # libgstpbutils-1.0.so.0
    # libgstvideo-1.0.so.0
    gst_all_1.gst-plugins-base
    # libgstbase-1.0.so.0
    # libgstreamer-1.0.so.0
    gst_all_1.gstreamer
    # libgssapi_krb5.so.2
    krb5
    # libgcc_s.so.1
    # libstdc++.so.6
    libgcc
    # libEGL.so.1
    # libGL.so.1
    libGL
    # libpulse-mainloop-glib.so.0
    # libpulse.so.0
    libpulseaudio
    # libX11.so.6
    # libX11-xcb.so.1
    libx11
    # libxcb-glx.so.0
    # libxcb-randr.so.0
    # libxcb-render.so.0
    # libxcb-shape.so.0
    # libxcb-shm.so.0
    # libxcb.so.1
    # libxcb-sync.so.1
    # libxcb-xfixes.so.0
    # libxcb-xinerama.so.0
    # libxcb-xkb.so.1
    libxcb
    # libxcb-image.so.0
    libxcb-image
    # libxcb-keysyms.so.1
    libxcb-keysyms
    # libxcb-render-util.so.0
    libxcb-render-util
    # libxcb-util.so.1
    libxcb-util
    # libxcb-icccm.so.4
    libxcb-wm
    # libXext.so.6
    libxext
    # libxkbcommon.so.0
    # libxkbcommon-x11.so.0
    libxkbcommon
    # libz.so.1
    zlib
  ];

  unpackPhase = ''
    runHook preUnpack

    unzip "$src"

    run=$(ls *.run)
    offset=$(LC_ALL=C grep -abo $'\xfd7zXZ\x00' $run | cut -d: -f1)
    dd if=$run iflag=skip_bytes skip=$offset of=payload.tar.xz
    xz -dc --single-stream payload.tar.xz | tar x

    runHook postUnpack
  '';

  sourceRoot = "MelGeekHive";

  postPatch = ''
    sed -i com.melgeek.melgeekhive.desktop \
      -e '/^Icon=/s/=.*/=com.melgeek.melgeekhive/' \
      -e '/^Exec=/s/=.*/=melgeekhive/'
  '';

  installPhase = ''
    runHook preInstall

    rm -rf 70-melgeekhive_devices.rules 7z AppRun AppRun.sh com.melgeek.melgeekhive.policy UpdateProgram

    mkdir -p $out/share/applications
    mv com.melgeek.melgeekhive.desktop $out/share/applications

    mkdir -p $out/share/icons/hicolor/scalable/apps
    mv com.melgeek.melgeekhive.svg $out/share/icons/hicolor/scalable/apps

    mkdir -p $out/opt/MelGeekHive
    cp -r 'MelGeek Hive' default extends lib plugins qml qt.conf resources translations $out/opt/MelGeekHive

    mkdir -p $out/bin
    ln -s "$out/opt/MelGeekHive/MelGeek Hive" $out/bin/melgeekhive

    runHook postInstall
  '';

  meta = {
    description = "Configuration software for MelGeek devices";
    homepage = "https://www.melgeek.com/en-jp/pages/hive";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "melgeekhive";
    platforms = [ "x86_64-linux" ];
  };
})
