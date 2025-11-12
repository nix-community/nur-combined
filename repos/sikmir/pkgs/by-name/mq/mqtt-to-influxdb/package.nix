{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  spdlog,
  yaml-cpp,
  libcpr_1_10_5,
  cxxopts,
  nlohmann_json,
  influxdb-cxx,
  boost,
  curl,
  paho-mqtt-cpp,
  paho-mqtt-c,
  stduuid,
  microsoft-gsl,
  catch2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mqtt-to-influxdb";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "DavidHamburg";
    repo = "mqtt-to-influxdb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rTMI9gqjtrmtT9SoYcHHq19Jch1dH7/tmyqz5F4f9Ao=";
    fetchSubmodules = true;
  };

  postPatch =
    ''
      substituteInPlace src/app/CMakeLists.txt \
        --replace-fail "/usr" "$out"
      sed -i '1i #include <iostream>' src/app-validate/main.cpp
      substituteInPlace src/app-validate/main.cpp \
        --replace-fail "OptionParseException" "exceptions::parsing"
      substituteInPlace src/app/main.cpp \
        --replace-fail "OptionParseException" "exceptions::parsing"
    ''
    + lib.optionalString stdenv.cc.isClang ''
      substituteInPlace src/libmqtt-to-influxdb/CMakeLists.txt \
        --replace-fail "stdc++fs" ""
    '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    spdlog
    yaml-cpp
    libcpr_1_10_5
    cxxopts
    nlohmann_json
    influxdb-cxx
    boost
    curl
    paho-mqtt-cpp
    paho-mqtt-c
    stduuid
    microsoft-gsl
    catch2
  ];

  meta = {
    description = "MQTT message parser for writing statistics into InfluxDB";
    homepage = "https://github.com/DavidHamburg/mqtt-to-influxdb";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
