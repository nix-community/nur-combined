{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  nix-update-script,
  libsForQt5,
  qt6Packages,
  versionCheckHook,
  alsa-lib,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  gtk4,
  libgcc,
  libgbm,
  libkrb5,
  libva,
  libX11,
  libxcb,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libxkbcommon,
  libXrandr,
  nspr,
  nss,
  pango,
  pipewire,
  udev,
  wayland,
}:

let
  desktopItem = makeDesktopItem {
    name = "fingerprint-chromium";
    desktopName = "Fingerprint Chromium";
    exec = "fingerprint-chromium %U";
    icon = "fingerprint-chromium";
    categories = [
      "Network"
      "WebBrowser"
    ];
    mimeTypes = [
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "text/html"
      "application/pdf"
    ];
    startupNotify = true;
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "fingerprint-chromium-bin";
  version = "150.0.7871.186";

  src = fetchurl {
    url = "https://github.com/adryfish/fingerprint-chromium/releases/download/${finalAttrs.version}/ungoogled-chromium-${finalAttrs.version}-1-x86_64_linux.tar.xz";
    hash = "sha256-SO/4YAU+/ZrUmNUTcPCh9Z+YPfOcAqcq0qhoLN6tQFU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  desktopItems = [ desktopItem ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    libgcc
    libgbm
    libX11
    libxcb
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libxkbcommon
    libXrandr
    nspr
    nss
    pango
    udev
    # Qt theme-integration shims (libqt{5,6}_shim.so are dlopened when
    # QT_QPA_PLATFORMTHEME is set) need the real Qt libraries' lib entries.
    (lib.getLib libsForQt5.qtbase)
    (lib.getLib qt6Packages.qtbase)
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    libExec="$out/libexec/fingerprint-chromium"
    mkdir -p "$libExec" "$out/bin"
    cp -r . "$libExec/"

    makeWrapper "$libExec/chrome" "$out/bin/fingerprint-chromium" \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          gtk3
          gtk4
          libkrb5
          libva
          pipewire
          wayland
        ]
      } \
      --run "${''
        if [ -x "/run/wrappers/bin/__chromium-suid-sandbox" ]; then
          export CHROME_DEVEL_SANDBOX="/run/wrappers/bin/__chromium-suid-sandbox"
        fi
      ''}" \
      --set CHROME_WRAPPER fingerprint-chromium \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    install -Dm644 product_logo_48.png $out/share/pixmaps/fingerprint-chromium.png

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/adryfish/fingerprint-chromium/releases";
    description = "Fingerprint browser based on ungoogled-chromium, prebuilt Linux binaries";
    homepage = "https://github.com/adryfish/fingerprint-chromium";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "fingerprint-chromium";
  };
})
