{ lib
, stdenv
, fetchFromGitHub
, cmake
, spdlog
, libyamlcpp
, libcpr
, cxxopts
, nlohmann_json
, influxdb-cxx
, boost
, curl
, paho-mqtt-cpp
, paho-mqtt-c
, stduuid
, microsoft_gsl
, catch2
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mqtt-to-influxdb";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "DavidHamburg";
    repo = "mqtt-to-influxdb";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rTMI9gqjtrmtT9SoYcHHq19Jch1dH7/tmyqz5F4f9Ao=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace src/app/CMakeLists.txt \
      --replace-fail "/usr" "$out"
    sed -i '1i #include <iostream>' src/app-validate/main.cpp
    substituteInPlace src/app-validate/main.cpp \
      --replace-fail "OptionParseException" "exceptions::parsing"
    substituteInPlace src/app/main.cpp \
      --replace-fail "OptionParseException" "exceptions::parsing"
  '' + lib.optionalString stdenv.cc.isClang ''
    substituteInPlace src/libmqtt-to-influxdb/CMakeLists.txt \
      --replace-fail "stdc++fs" ""
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    spdlog
    libyamlcpp
    libcpr
    cxxopts
    nlohmann_json
    influxdb-cxx
    boost
    curl
    paho-mqtt-cpp
    paho-mqtt-c
    stduuid
    microsoft_gsl
    catch2
  ];

  meta = with lib; {
    description = "MQTT message parser for writing statistics into InfluxDB";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
