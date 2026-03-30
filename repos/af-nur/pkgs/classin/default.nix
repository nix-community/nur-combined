{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper

, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, e2fsprogs
, expat
, fontconfig
, freetype
, glib
, keyutils
, libGL
, libdrm
, libice
, libkrb5
, libselinux
, libsm
, libuuid
, libx11
, libxcb
, libxcomposite
, libxcursor
, libxdamage
, libxext
, libxfixes
, libxi
, libxinerama
, libxkbcommon
, libxrandr
, libxrender
, libxscrnsaver
, libxtst
, mesa
, nspr
, nss
, pango
, pcre
, pixman
, pulseaudio
, systemd
, util-linux
, xcbutilimage
, xcbutilkeysyms
, xcbutilrenderutil
, xcbutilwm
, openssl_1_1
}:

stdenv.mkDerivation rec {
  pname = "classin";
  version = "6.0.5.4007";

  src = fetchurl {
    url = "https://www.eeo.cn/download/client/classin_${version}_amd64.deb";
    hash = "sha256-xAp1NzUrbIwoVVGzwTwov5IsdYlrvrzVSYVdyKijPxc=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib at-spi2-atk at-spi2-core atk cairo cups dbus e2fsprogs expat
    fontconfig freetype glib keyutils libGL libdrm libice libkrb5 libselinux
    libsm libuuid libx11 libxcb libxcomposite libxcursor libxdamage libxext
    libxfixes libxi libxinerama libxkbcommon libxrandr libxrender libxscrnsaver
    libxtst mesa nspr nss pango pcre pixman pulseaudio systemd util-linux
    xcbutilimage xcbutilkeysyms xcbutilrenderutil xcbutilwm
    openssl_1_1
  ];

  unpackPhase = "dpkg-deb -x $src .";

  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt/apps/classin $out/bin $out/share
    cp -r opt/apps/classin/* $out/opt/apps/classin/
    
    if [ -d usr/share ]; then
      cp -r usr/share/* $out/share/
    fi

    pushd $out/opt/apps/classin/lib
    rm -f libpixman-1.so* libselinux.so* libcairo.so* libglib-2.0.so* \
          libgio-2.0.so* libgobject-2.0.so* libgmodule-2.0.so* \
          libgthread-2.0.so* libdbus-1.so* libfontconfig.so* \
          libfreetype.so* libz.so* libstdc++.so* libgcc_s.so* \
          libblkid.so* libmount.so* libpcre.so* libcrypto.so* \
          libssl.so* libxcb*
    popd

    if [ -f $out/share/applications/classin.desktop ]; then
      substituteInPlace $out/share/applications/classin.desktop \
        --replace "Exec=/usr/bin/classin" "Exec=classin"
    fi
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/opt/apps/classin/ClassIn $out/bin/classin \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}:$out/opt/apps/classin/lib" \
      --set QT_QPA_PLATFORM x11 \
      --chdir "$out/opt/apps/classin" \
      --add-flags "--no-sandbox"
  '';

  meta = with lib; {
    description = "ClassIn Online Interactive Classroom";
    homepage = "https://www.eeo.cn/";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}