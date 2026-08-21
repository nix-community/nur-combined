{
  lib,
  stdenv,
  fetchFromGitHub,
  qt6,
  qt6Packages,
  openssl,
  ppp,
}:
stdenv.mkDerivation rec {
  pname = "openfortigui";
  version = "0.9.11";

  src = fetchFromGitHub {
    owner = "theinvisible";
    repo = "openfortigui";
    rev = "v${version}-1";
    hash = "sha256-Bcw4cGbJDHISUi3q8lnBhia3Z0BGLmsE3NVT6C4YvPw=";
    fetchSubmodules = true;
  };

  buildInputs = [
    qt6.qtbase
    openssl
    qt6Packages.qtkeychain
  ];

  nativeBuildInputs = [
    qt6.qmake
    qt6.qttools
    qt6.wrapQtAppsHook
  ];

  postPatch = ''
    sed -i 's|/usr/sbin/pppd|${ppp}/bin/pppd|g' openfortigui/openfortigui.pro
    substituteInPlace openfortigui/openfortigui.pro \
      --replace-fail '-lqt5keychain' '-lqt6keychain'
    substituteInPlace \
      openfortigui/vpngroupeditor.cpp \
      openfortigui/vpnprofileeditor.cpp \
      openfortigui/proc/vpnbarracuda.cpp \
      openfortigui/proc/vpnprocess.cpp \
      --replace-fail 'QRegExp' 'QRegularExpression'
    substituteInPlace \
      openfortigui/ticonfmain.cpp \
      openfortigui/vpnhelper.cpp \
      --replace-fail 'qt5keychain/keychain.h' 'qt6keychain/keychain.h'
    substituteInPlace openfortigui/ticonfmain.cpp \
      --replace-fail '#include <QValidator>' '#include <QRegularExpression>' \
      --replace-fail 'QRegExp' 'QRegularExpression' \
      --replace-fail 'rexpName.exactMatch(profile.name)' 'rexpName.match(profile.name).hasMatch()' \
      --replace-fail 'rexpName.exactMatch(vpnprofilename)' 'rexpName.match(vpnprofilename).hasMatch()' \
      --replace-fail 'rexpName.exactMatch(group.name)' 'rexpName.match(group.name).hasMatch()' \
      --replace-fail 'rexpName.exactMatch(vpngroupname)' 'rexpName.match(vpngroupname).hasMatch()'
    sed -i '/#include <QTimer>/a #include <QRegularExpression>' openfortigui/proc/vpnbarracuda.cpp
    substituteInPlace openfortigui/vpnhelper.cpp \
      --replace-fail 'proc.start(cmd, QIODevice::ReadOnly);' 'proc.startCommand(cmd, QIODevice::ReadOnly);'
    substituteInPlace openfortigui/mainwindow.cpp \
      --replace-fail '#include <QDesktopWidget>' '#include <QGuiApplication>'
    # Qt6 removed QSignalMapper::mapped(QString); it was renamed to mappedString(QString).
    # The old string-based connect() fails silently at runtime, which breaks VPN
    # start actions AND the OTP prompt pipeline (readyReadStandardOutput -> mapper ->
    # logVPNOutput never fires, so the OTP-Login window never appears). Rename to the
    # Qt6 signal in every QSignalMapper connect (mainwindow.cpp x2, vpnlogger.cpp x2).
    sed -i 's|SIGNAL(mapped(QString))|SIGNAL(mappedString(QString))|g' \
      openfortigui/mainwindow.cpp \
      openfortigui/vpnlogger.cpp
    substituteInPlace openfortigui/setupwizard.cpp \
      --replace-fail '#include <QDateTime>' '#include <QRandomGenerator>' \
      --replace-fail '    qsrand(QTime::currentTime().msec());' '    // QRandomGenerator is seeded securely by Qt.' \
      --replace-fail 'qrand()' 'QRandomGenerator::global()->generate()'

    substituteInPlace openfortigui/app-entry/openfortigui.desktop \
      --replace-fail '/usr/bin/openfortigui' 'openfortigui' \
      --replace-fail '/usr/share/pixmaps/openfortigui.png' 'openfortigui'
  '';

  preConfigure = ''
    mkdir -p build
    cd build
  '';

  qmakeFlags = ["../openfortigui/openfortigui.pro"];

  installPhase = ''
    runHook preInstall

    install -Dm755 openfortigui $out/bin/openfortigui
    install -Dm644 ../openfortigui/app-entry/openfortigui.desktop $out/share/applications/openfortigui.desktop
    install -Dm644 ../openfortigui/app-entry/openfortigui.png $out/share/pixmaps/openfortigui.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "GUI for openfortivpn (FortiGate VPN client)";
    homepage = "https://github.com/theinvisible/openfortigui";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = ["Ahmet Çetinkaya <contact@ahmetcetinkaya.me>"];
  };
}
