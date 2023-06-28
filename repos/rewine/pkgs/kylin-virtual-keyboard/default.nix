{ lib
, stdenv
, fetchgit
, qmake
, qttools
, wrapQtAppsHook
, qtwayland
, kwindowsystem
, fcitx5-qt
, qtquickcontrols2
, qtdeclarative
, qtgraphicaleffects
}:

stdenv.mkDerivation rec {
  pname = "kylin-virtual-keyboard";
  version = "2.0.1.0-0ok5";

  src = fetchgit {
    url = "https://gitee.com/openkylin/kylin-virtual-keyboard";
    rev = "5a4ee6f77a02726c9d46ac3ee99237542cbe6a39";
    hash = "sha256-euaJX+Ab3hoaM85tpCn2SMqrSMi3cpPG4ruFi2N0src=";
  };

  postPatch = ''
    substituteInPlace kylin-virtual-keyboard.pro \
     data/org.fcitx.Fcitx5.VirtualKeyboard.service \
     debian/{kylin-virtual-keyboard.desktop,kylin-virtual-keyboard-xwayland} \
      --replace /usr $out
  '';

  nativeBuildInputs = [
    qmake
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    qtwayland
    kwindowsystem
    fcitx5-qt
    qtquickcontrols2
    qtdeclarative
    qtgraphicaleffects
  ];

  postInstall = ''
    install -D data/org.fcitx.Fcitx5.VirtualKeyboard.service -t $out/share/dbus-1/services/
    install -D debian/kylin-virtual-keyboard.desktop -t $out/etc/xdg/autostart/
    install -D debian/kylin-virtual-keyboard-xwayland -t $out/bin/
  '';

  meta = with lib; {
    description = "";
    homepage = "https://gitee.com/openkylin/kylin-virtual-keyboard";
    #license = with licenses; [ ];
    maintainers = with maintainers; [ rewine ];
  };
}
