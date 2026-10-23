{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "shirok1";
  domain = "lumi_curtain";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "shirok1";
    repo = "hass-lumi-curtain";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4HgmgRG4rlv+Ojab0R4ahZw6Ak2YEfblkM+YHJmqLEQ=";
  };

  dependencies = with home-assistant.python3Packages; [
    bleak
    bleak-retry-connector
    cryptography
  ];

  meta = {
    description = "Local Bluetooth control of Aqara HMCN02 curtains for Home Assistant";
    homepage = "https://github.com/shirok1/hass-lumi-curtain";
    license = lib.licenses.asl20;
  };
})
