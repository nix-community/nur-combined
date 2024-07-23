{ makeDesktopItem, stdenv, appimageTools, lib, fetchurl,
  cacert, glib-networking, ... }:
let
  pname = "onekey-wallet";
  version = "5.0.1";
  sha256 = "sha256-UrOD3uSxcfLt2kTwaWCvUOnjuDfITx6444vBl5kQYm0=";
  url = "https://web.onekey-asset.com/app-monorepo/v${version}/OneKey-Wallet-${version}-linux-x86_64.AppImage";
  src = fetchurl {
    inherit url sha256;
  };
  extractedContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
                         install -m 444 -D ${extractedContents}/onekey-wallet.desktop $out/share/applications/onekey-wallet.desktop
                         install -m 444 -D ${extractedContents}/usr/share/icons/hicolor/0x0/apps/onekey-wallet.png \
                           $out/share/icons/hicolor/512x512/onekey-wallet.png
                         substituteInPlace $out/share/applications/onekey-wallet.desktop --replace-fail 'Exec=AppRun --no-sandbox' 'Exec=${pname}'
                         '';

  # You should also add udev rules into your system to make hardware wallet connect to your system
  # onekey = builtins.fetchurl {
  #   url = "https://data.onekey.so/onekey.rules";
  #   sha256 = "sha256:0rx7xv6mddbcfa16kwd7j5nwmxlm9p23vpig13nmwqyq2f3drxav";
  # };
  # services.udev.extraRules = [ (builtins.readFile onekey) ]
  meta = with lib; {
    description = "OneKey App is a wallet application designed and developed by OneKey, comprising a desktop client, a mobile application, and a browser extension. It can be used with the OneKey hardware wallet or as a standalone software wallet to help you manage and safeguard your crypto assets.";
    homepage = "https://onekey.so";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
