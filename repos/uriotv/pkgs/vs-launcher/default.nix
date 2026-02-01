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
  pname = "vs-launcher";
  version = "1.5.8";
  src = fetchurl {
    url = "https://github.com/XurxoMF/vs-launcher/releases/download/${version}/vs-launcher-${version}.AppImage";
    sha256 = "0y70h1g1yc9d214ppvg32wfmi6jhmvhi6d98f5y8mcm7zdx4x22s";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
  fhs = buildFHSEnv {
    name = "vs-launcher";

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
  name = "vs-launcher";
  paths = [ fhs ];
  postBuild = ''
    mkdir -p $out/share/applications $out/share/icons

    # Find the desktop file (name might vary slightly)
    cp ${appimageContents}/*.desktop $out/share/applications/vs-launcher.desktop

    substituteInPlace $out/share/applications/vs-launcher.desktop \
      --replace "Exec=AppRun" "Exec=vs-launcher" \
      --replace "Icon=vs-launcher" "Icon=vs-launcher"
      
    cp -r ${appimageContents}/usr/share/icons/* $out/share/icons/
  '';

  meta = with lib; {
    description = "Unofficial Vintage Story Launcher";
    homepage = "https://github.com/XurxoMF/vs-launcher";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "vs-launcher";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
