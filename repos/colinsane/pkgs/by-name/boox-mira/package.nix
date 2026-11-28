{
  appimageTools,
  buildFHSEnv,
  fetchurl,
  lib,
  writeShellScript,
}:
buildFHSEnv (finalAttrs: {
  pname = "boox-mira";
  version = "1.1.4";

  src = fetchurl {
    # N.B.: unversioned url, hash may drift; they don't appear to ship versioned archives anywhere.
    url = "https://static-us.boox.com/monitor-pc/linux/Mira-latest.AppImage";
    hash = "sha256-jVI2+jK2JUaXd6NEMpLi/KPRH60THJyORsHcyoaNLkk=";
  };

  contents = appimageTools.extract {
    inherit (finalAttrs) pname version src;
  };
  # The bundled Electron's GPU sandbox crashes inside the FHS environment.
  runScript = writeShellScript "boox-mira-start" ''
    exec appimage-exec.sh -w ${finalAttrs.contents} -- --disable-gpu --disable-gpu-sandbox "$@"
  '';

  # Avoid the generic AppImage environment's unrelated multimedia dependencies.
  targetPkgs = pkgs: [
    pkgs.appimageTools.appimage-exec
    pkgs.bash
    pkgs.coreutils
  ];
  multiPkgs =
    pkgs: with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      fontconfig
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libgbm
      libusb1
      libx11
      libxcb
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxkbcommon
      libxrandr
      libxrender
      libxscrnsaver
      libxtst
      nspr
      nss
      pango
      udev
    ];

  extraInstallCommands = ''
    install -Dm444 ${finalAttrs.contents}/mira.desktop $out/share/applications/boox-mira.desktop
    substituteInPlace $out/share/applications/boox-mira.desktop \
      --replace-fail "Exec=AppRun" "Exec=boox-mira"
    install -Dm444 ${finalAttrs.contents}/mira.png $out/share/icons/hicolor/1024x1024/apps/mira.png
  '';

  meta = {
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    description = "USB configuration GUI for BOOX Mira and Mira Pro e-ink monitors";
    homepage = "https://shop.boox.com/products/boox-mira-pro";
    mainProgram = "boox-mira";
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
