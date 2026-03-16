{
  pkgs,
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}: let
  inherit (pkgs.home-assistant.python.pkgs) tuya-iot-py-sdk pycountry;
in
  buildHomeAssistantComponent rec {
    owner = "jbsky";
    domain = "tuya_ble";
    version = "0.2.4";

    src = fetchFromGitHub {
      inherit owner;
      repo = "ha_tuya_ble";
      rev = version;
      hash = "sha256-PeRXoqYNhJFzqeuqp7JA41xqlfxljaIuqr1hVSJvaGM=";
    };

    dependencies = [
      tuya-iot-py-sdk
      pycountry
    ];

    passthru.isHomeAssistantComponent = true;

    meta = with lib; {
      changelog = "https://github.com/jbsky/ha_tuya_ble/releases/tag/${version}";
      description = "Home Assistant support for Tuya BLE devices ";
      homepage = "https://github.com/jbsky/ha_tuya_ble";
      maintainers = [];
      license = licenses.mit;
      sourceProvenance = [sourceTypes.fromSource];
    };
  }
