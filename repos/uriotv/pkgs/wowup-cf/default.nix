{
  lib,
  fetchurl,
  appimageTools,
  buildFHSEnv,
  symlinkJoin,
  electron,
  mesa,
  ...
}:

let
  pname = "wowup-cf";
  version = "2.22.0";
  src = fetchurl {
    url = "https://github.com/WowUp/WowUp.CF/releases/download/v${version}/WowUp-CF-${version}.AppImage";
    sha256 = "0a2s3dnh7b79b1fjbxh8cnchdnih2p5ny7liq10r818q7sg0762z";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
  fhs = buildFHSEnv {
    name = "wowup-cf";

    targetPkgs =
      pkgs: with pkgs; [
        udev
        alsa-lib
        nss
        nspr
        mesa
        libglvnd
        vulkan-loader
        gtk3
        cairo
        pango
        atk
        gdk-pixbuf
        glib
        dbus
        libdrm
        libnotify
        libsecret
        xorg.libX11
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXrandr
        xorg.libxcb
        wayland
        cups
        expat
        libuuid
        at-spi2-atk
        at-spi2-core
        # Electron dependency
        electron
      ];

    runScript = "electron ${appimageContents}/resources/app.asar";

    multiPkgs = pkgs: [ pkgs.mesa ];
  };
in
symlinkJoin {
  name = "wowup-cf";
  paths = [ fhs ];
  postBuild = ''
    mkdir -p $out/share/applications $out/share/icons
    cp ${appimageContents}/wowup-cf.desktop $out/share/applications/
    substituteInPlace $out/share/applications/wowup-cf.desktop \
      --replace "Exec=AppRun" "Exec=wowup-cf" \
      --replace "Icon=wowup-cf" "Icon=wowup-cf"
    cp -r ${appimageContents}/usr/share/icons/* $out/share/icons/
  '';

  meta = with lib; {
    description = "World of Warcraft addon manager with CurseForge support";
    homepage = "https://github.com/WowUp/WowUp.CF";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "wowup-cf";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
