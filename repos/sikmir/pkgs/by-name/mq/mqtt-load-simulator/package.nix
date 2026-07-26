{
  lib,
  stdenv,
  fetchFromGitHub,
  qt5,
  qmqtt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mqtt-load-simulator";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "halfgaar";
    repo = "MqttLoadSimulator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XXU5ghCD2rRrZArVzi97oZukCWYGgpXLNhUAztFeyjw=";
  };

  postPatch = ''
    sed -i "23i typedef unsigned int uint;" clientnumberpool.h
    substituteInPlace MqttLoadSimulator.pro \
      --replace-fail "QT += network qmqtt" "QT += network" \
      --replace-fail "/opt" "$out"
    cat >> MqttLoadSimulator.pro <<"EOF"
    LIBS += -L${qmqtt}/lib -lqmqtt
    EOF
  '';

  sourceRoot = "${finalAttrs.src.name}/MqttLoadSimulator";

  nativeBuildInputs = [
    qt5.qmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [ (qmqtt.override { qt6 = qt5; }) ];

  postInstall = ''
    mv $out/MqttLoadSimulator/* $out
    rm -r $out/MqttLoadSimulator
  '';

  meta = {
    description = "Simulate MQTT load / MQTT stress tester";
    homepage = "https://github.com/halfgaar/MqttLoadSimulator";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "MqttLoadSimulator";
  };
})
