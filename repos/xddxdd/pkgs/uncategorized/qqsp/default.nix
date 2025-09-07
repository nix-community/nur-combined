{
  stdenv,
  lib,
  sources,
  libsForQt5,
  qt5,
}:
stdenv.mkDerivation {
  inherit (sources.qqsp) pname version src;

  nativeBuildInputs = [
    libsForQt5.qmake
    qt5.wrapQtAppsHook
  ];
  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtmultimedia
    libsForQt5.qtwebengine
    libsForQt5.qtwebchannel
  ];

  qmakeFlags = [ "Qqsp.pro" ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  postPatch = ''
    sed -i "s|/usr/bin/||g" Qqsp.desktop
    sed -i 's/;\s*$//g' Qqsp.desktop
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 Qqsp $out/bin/Qqsp
    install -Dm644 Qqsp.desktop $out/share/applications/Qqsp.desktop
    install -Dm644 qsp.mime $out/share/mime/packages/qsp.xml
    install -Dm644 icons/qsp-logo-vector.svg $out/share/icons/hicolor/scalable/apps/qsp.svg

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "QT Quest Soft Player is a interactive fiction stories and games player (compatible fork of qsp.su)";
    homepage = "https://github.com/Sonnix1/Qqsp";
    license = lib.licenses.mit;
    mainProgram = "Qqsp";
  };
}
