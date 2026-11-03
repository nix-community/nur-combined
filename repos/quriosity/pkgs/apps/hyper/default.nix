{ lib
, stdenv
, appimageTools
, fetchurl
, makeDesktopItem
, makeWrapper
, autoPatchelfHook
, nix-update-script
, glib
, pango
, gtk3
, systemd
, alsa-lib
, nss
, nspr
, pyfa
, cups
, cairo
, dbus-glib
, libGL
, libglvnd
, libgcc
, libgbm
, libX11
, libXcomposite
, libXdamage
, libXfixes
, libXrandr
, libXext
, libxcb
}:

let
  pname = "hyper";
  version = "4.0.0-q";

  src = fetchurl {
    url = "https://github.com/quine-global/hyper/releases/download/v${version}-canary.14/Hyper-${version}-canary.13-x86_64.AppImage";
    hash = "sha256-0iV+0fC50J7lEKtKjCTQWqrh5HVmv/dhjqKULAci7V8=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "${pname} --no-sandbox %U";
    icon = pname;
    desktopName = "Hyper";
    comment = "A terminal built on web technologies";
    categories = [ "TerminalEmulator" ];
    startupWMClass = "Hyper";
    mimeTypes = [
      "x-scheme-handler/ssh"
    ];
  };

  runtimeLibPath = lib.makeLibraryPath [
    libGL
    libglvnd
    libgbm
  ];
in
stdenv.mkDerivation {
  inherit pname version;
  src = appimageContents;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    glib
    pango
    gtk3
    systemd
    alsa-lib
    nss
    nspr
    pyfa
    cups
    cairo
    dbus-glib
    libGL
    libglvnd
    libgcc
    libgbm
    libX11
    libXcomposite
    libXdamage
    libXfixes
    libXrandr
    libXext
    libxcb
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/hyper $out/bin
    cp -r . $out/opt/hyper

    # The AppImage bundles legacy GTK2 libappindicator/libindicator libraries
    # from older Electron releases. Current Electron implements the system tray
    # over D-Bus (StatusNotifierItem), so drop them to avoid a GTK2 dependency.
    rm -f $out/opt/hyper/usr/lib/libappindicator.so.1 \
          $out/opt/hyper/usr/lib/libindicator.so.7

    makeWrapper $out/opt/hyper/hyper $out/bin/hyper \
      --add-flags "--no-sandbox" \
      --prefix LD_LIBRARY_PATH : "${runtimeLibPath}:/run/opengl-driver/lib"

    install -m 444 -D ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop

    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/256x256/apps/hyper.png \
      $out/share/icons/hicolor/256x256/apps/${pname}.png

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "a terminal built on web technologies";
    homepage = "https://github.com/quine-global/hyper";
    license = licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "hyper";
  };
}
