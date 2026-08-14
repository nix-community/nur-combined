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
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "classin";
  # Note: the official Linux amd64/arm64 builds are not version-synced
  # (see https://www.eeo.cn/sysshare/custom/download_conf.json).
  version = if stdenv.hostPlatform.isAarch64 then "6.0.8.2738" else "6.0.8.2737";

  src = fetchurl {
    url = if stdenv.hostPlatform.isAarch64 then
      "https://www.eeo.cn/download/client/classin_${finalAttrs.version}_arm64.deb"
    else
      "https://www.eeo.cn/download/client/classin_${finalAttrs.version}_amd64.deb";
    hash = if stdenv.hostPlatform.isAarch64 then
      "sha256-35qdkyKoTjYDiNvdxH3ila1xvFrWHJk4FMiATm/+UjA="
    else
      "sha256-w+hx6vbygQ0Mn/sW9CWaapd4T27XMPQifd3vZoLXPgc=";
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
    # Keep the bundled libssl.so.1.1/libcrypto.so.1.1 — classin's libavformat.so
    # needs the OpenSSL 1.1 ABI, which nixpkgs no longer provides
    # (openssl_1_1 was removed upstream).
    rm -f libpixman-1.so* libselinux.so* libcairo.so* libglib-2.0.so* \
          libgio-2.0.so* libgobject-2.0.so* libgmodule-2.0.so* \
          libgthread-2.0.so* libdbus-1.so* libfontconfig.so* \
          libfreetype.so* libz.so* libstdc++.so* libgcc_s.so* \
          libblkid.so* libmount.so* libpcre.so* libxcb*
    popd

    if [ -f $out/share/applications/classin.desktop ]; then
      substituteInPlace $out/share/applications/classin.desktop \
        --replace "Exec=/usr/bin/classin" "Exec=classin"
    fi
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/opt/apps/classin/ClassIn $out/bin/classin \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}:$out/opt/apps/classin/lib" \
      --set QT_QPA_PLATFORM x11 \
      --chdir "$out/opt/apps/classin" \
      --add-flags "--no-sandbox"
  '';

  meta = with lib; {
    description = "ClassIn Online Interactive Classroom";
    homepage = "https://www.eeo.cn/";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = [ ];
  };
})