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
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk3
, libGL
, libdrm
, libnotify
, libsecret
, libx11
, libxcb
, libxcomposite
, libxdamage
, libxext
, libxfixes
, libxkbcommon
, libxkbfile
, libxrandr
, mesa
, nspr
, nss
, pango
, systemd
, xdg-utils
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aiot-ide";
  version = "1.7.0";

  src = fetchurl {
    url = "https://vela-ide.cnbj3-fusion.mi-fds.com/vela-ide/ide/v${finalAttrs.version}/AIoT_IDE_ubuntu.deb";
    hash = "sha256-N4Cf3hbKx4OOdX6BdUI28jWvcYClbs9Ax4rYAw9VM+Y=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib at-spi2-atk at-spi2-core atk cairo cups dbus expat
    fontconfig freetype gdk-pixbuf glib gtk3 libGL libdrm libnotify
    libsecret libx11 libxcb libxcomposite libxdamage libxext libxfixes
    libxkbcommon libxkbfile libxrandr mesa nspr nss pango systemd
  ];

  # The deb ships chrome-sandbox with mode 4755; dpkg-deb -x would try to
  # restore that setuid bit and fail inside the Nix sandbox.
  unpackPhase = ''
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-owner --no-same-permissions
  '';

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share $out/bin
    cp -r usr/share/* $out/share/

    substituteInPlace $out/share/applications/aiot-ide.desktop \
      --replace-fail "Exec=/usr/share/aiot-ide/aiot-ide %F" "Exec=aiot-ide %F" \
      --replace-fail "Exec=/usr/share/aiot-ide/aiot-ide --new-window %F" "Exec=aiot-ide --new-window %F"
    substituteInPlace $out/share/applications/aiot-ide-url-handler.desktop \
      --replace-fail "Exec=/usr/share/aiot-ide/aiot-ide --open-url %U" "Exec=aiot-ide --open-url %U"

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/share/aiot-ide/bin/aiot-ide $out/bin/aiot-ide \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}:$out/share/aiot-ide" \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '';

  meta = with lib; {
    description = "AIoT IDE for Xiaomi Vela QuickApp development, prebuilt binary release";
    homepage = "https://iot.mi.com/vela/quickapp/zh/tools/";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    license = licenses.unfree;
    mainProgram = "aiot-ide";
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
})
