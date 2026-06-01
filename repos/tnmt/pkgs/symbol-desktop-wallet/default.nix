{
  stdenv,
  lib,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  nix-update-script,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libnotify,
  libsecret,
  libusb1,
  libuuid,
  libxcb,
  libxkbcommon,
  libxkbfile,
  libxshmfence,
  libxtst,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
  xorg,
}:
stdenv.mkDerivation rec {
  pname = "symbol-desktop-wallet";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/symbol/desktop-wallet/releases/download/v${version}/symbol-desktop-wallet-linux-amd64-${version}.deb";
    hash = "sha256-HaqQURzvgNxt1yePl8FXG2L2hoDxCSJkUCZesMG4g0w=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libnotify
    libsecret
    libusb1
    libuuid
    libxcb
    libxkbcommon
    libxkbfile
    libxshmfence
    libxtst
    mesa
    nspr
    nss
    pango
    systemd
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  dontBuild = true;
  dontConfigure = true;
  dontWrapGApps = true;

  autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt $out/bin $out/share/applications

    cp -r "opt/Symbol Wallet" "$out/opt/Symbol Wallet"
    cp -r usr/share/icons $out/share/icons

    install -Dm644 usr/share/applications/symbol-desktop-wallet.desktop \
      $out/share/applications/symbol-desktop-wallet.desktop

    substituteInPlace $out/share/applications/symbol-desktop-wallet.desktop \
      --replace-fail '"/opt/Symbol Wallet/symbol-desktop-wallet"' \
      "$out/bin/symbol-desktop-wallet"

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper "$out/opt/Symbol Wallet/symbol-desktop-wallet" \
      "$out/bin/symbol-desktop-wallet" \
      --add-flags "--no-sandbox" \
      "''${gappsWrapperArgs[@]}"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Official desktop wallet for the Symbol blockchain";
    homepage = "https://github.com/symbol/desktop-wallet";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "symbol-desktop-wallet";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
