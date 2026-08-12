{
  stdenv,
  lib,
  fetchurl,
  dpkg,
  copyDesktopItems,
  makeWrapper,
  electron,
  nix-update-script,
}:
stdenv.mkDerivation rec {
  pname = "symbol-desktop-wallet";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/symbol/desktop-wallet/releases/download/v${version}/symbol-desktop-wallet-linux-amd64-${version}.deb";
    hash = "sha256-HaqQURzvgNxt1yePl8FXG2L2hoDxCSJkUCZesMG4g0w=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    dpkg
    makeWrapper
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/symbol-desktop-wallet"
    cp "opt/Symbol Wallet/resources/app.asar" \
      "$out/share/symbol-desktop-wallet/app.asar"
    cp -r "opt/Symbol Wallet/resources/app.asar.unpacked" \
      "$out/share/symbol-desktop-wallet/app.asar.unpacked"

    cp -r usr/share/icons "$out/share/icons"

    install -Dm644 usr/share/applications/symbol-desktop-wallet.desktop \
      "$out/share/applications/symbol-desktop-wallet.desktop"
    substituteInPlace "$out/share/applications/symbol-desktop-wallet.desktop" \
      --replace-fail '"/opt/Symbol Wallet/symbol-desktop-wallet" %U' \
      "$out/bin/symbol-desktop-wallet %U"

    makeWrapper "${lib.getExe electron}" "$out/bin/symbol-desktop-wallet" \
      --add-flags "$out/share/symbol-desktop-wallet/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+--ozone-platform-hint=auto}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Official desktop wallet for the Symbol blockchain";
    homepage = "https://github.com/symbol/desktop-wallet";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "symbol-desktop-wallet";
    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];
  };
}
