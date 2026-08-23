{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "zuyan9";
  domain = "cuktech_ble";
  version = "0.3.5-unstable";

  src = fetchFromGitHub {
    owner = "zuyan9";
    repo = "ha-cuk-ble";
    rev = "984d05dfcb7be17219cd35424574896542577844";
    hash = "sha256-tv5TQ9dNS2wjaJZCar9rmRAT0c3VzEzcNjX2lPp+tiM=";
  };

  dependencies = with home-assistant.python3Packages; [
    bleak
    bleak-retry-connector
    cryptography
  ];

  meta = {
    description = "Unofficial Home Assistant integration for the CUKTECH AD1204U charger (Mijia njcuk.fitting.ad1204), local BLE telemetry";
    homepage = "https://github.com/zuyan9/ha-cuk-ble";
    license = lib.licenses.asl20;
  };
})
