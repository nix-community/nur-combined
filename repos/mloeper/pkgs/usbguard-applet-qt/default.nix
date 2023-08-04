{ lib, stdenv, pkgs, fetchFromGitHub, ... }: 

stdenv.mkDerivation {
  pname = "usbguard-applet-qt";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "pinotree";
    repo = "usbguard-applet-qt";
    rev = "6f32dd18addc986cce6c868febea55e86fc936d9";
    hash = "sha256-9JI5G2u9LUXwiKyq+8xXsdSgdG8WJai0yalugr0HJr8=";
  };

  nativeBuildInputs = with pkgs; [ 
    cmake 
    pkg-config
    libsForQt5.qt5.wrapQtAppsHook
  ];

  buildInputs = with pkgs; [
    libsForQt5.qt5.qtbase
    libsForQt5.qt5.qttools
    usbguard
    libqb
  ];

  meta = with lib; {
    homepage = "https://github.com/pinotree/usbguard-applet-qt/tree/main";
    description = "Qt applet of USBGuard, as available before its removal from the USBGuard sources";
    longDescription = ''
      Displays a window asking the user what to do if the USB device is not allowed yet.
    '';
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "usbguard-applet-qt";
  };
}