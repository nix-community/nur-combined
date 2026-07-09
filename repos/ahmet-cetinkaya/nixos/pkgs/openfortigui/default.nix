{
  lib,
  stdenv,
  fetchFromGitHub,
  qt5,
  libsForQt5,
  openssl,
  ppp,
}:
stdenv.mkDerivation rec {
  pname = "openfortigui";
  version = "0.9.10";

  src = fetchFromGitHub {
    owner = "theinvisible";
    repo = "openfortigui";
    rev = "v${version}-1";
    hash = "sha256-SZ22o9NMBNqIzcJn2E3fNfpCmhVv7tFt3o/K+du4yhw=";
    fetchSubmodules = true;
  };

  buildInputs = [
    qt5.qtbase
    openssl
    libsForQt5.qtkeychain
  ];

  nativeBuildInputs = [
    qt5.qmake
    qt5.qttools
    qt5.wrapQtAppsHook
  ];

  postPatch = ''
    sed -i 's|/usr/sbin/pppd|${ppp}/bin/pppd|g' openfortigui/openfortigui.pro

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
