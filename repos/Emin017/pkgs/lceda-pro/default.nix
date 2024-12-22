{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  alsa-lib,
  gtk3,
  nss,
  unzip,
  glib,
  nspr,
  dbus,
  atk,
  cups,
  libdrm,
  pango,
  cairo,
  xorg,
  atkmm,
  libGL,
  mesa,
  expat,
  libxkbcommon,
  xcbutilwm,
  xcbutilimage,
  xcbutilkeysyms,
  xcbutilrenderutil,
  makeWrapper,
}:
let
  source-url = "https://image.lceda.cn/files/lceda-pro-linux-x64-2.2.27.1.zip";
  lceda-pro-runtime-xorg = with xorg; [
    libX11
    libXt
    libXext
    libSM
    libICE
    libxshmfence
    libXi
    libXft
    libXcursor
    libXfixes
    libXScrnSaver
    libXcomposite
    libXdamage
    libXtst
    libXrandr
    libxcb
  ];
  lceda-pro-runtime = [
    dpkg
    alsa-lib
    gtk3
    nss
    unzip
    glib
    nspr
    dbus
    atk
    atkmm
    cups
    libdrm
    pango
    cairo
    pango
    xcbutilwm
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    libxkbcommon
    libGL
    mesa
    expat
  ] ++ lceda-pro-runtime-xorg;
in
stdenv.mkDerivation {
    pname = "lceda-pro";
    version = "2.2.27.1";

    src = fetchurl {
      url = source-url;
      hash = "sha256-ejMfevAjMl9PN+UpJd2/TCF0ZaktQR+PRCgFE3pz59E=";
    };

    nativeBuildInputs = [ unzip makeWrapper ];

    unpackPhase = ''
      runHook preUnpack

      unzip $src

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp -r . $out/opt

      chmod +x $out/opt/lceda-pro/lceda-pro
      chmod +x $out/opt/lceda-pro/chrome-sandbox
      chmod +x $out/opt/lceda-pro/chrome_crashpad_handler

      wrapProgram $out/opt/lceda-pro/lceda-pro \
        --set LD_LIBRARY_PATH ${lib.makeLibraryPath lceda-pro-runtime}
      ln -s $out/opt/lceda-pro/lceda-pro $out/bin/lceda-pro

      runHook postInstall
    '';

    meta = with lib; {
      description = "A browser-based, user-friendly, powerful Electronics Design Automation tool";
      homepage = "https://lceda.cn/";
      license = licenses.unfree;
      platforms = [
        "x86_64-linux"
      ];
      mainProgram = "lceda-pro";
    };
}
