{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
}:

buildHomeAssistantComponent {
  owner = "shirok1";
  domain = "lumi_curtain";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "shirok1";
    repo = "hass-lumi-curtain";
    rev = "88e004ad18d40699a50a83bb670a634a20a918db";
    hash = "sha256-eJAl7JS2NOVlOC3nuMT1MeAVn3/+PN+rJUtev7xl8Ts=";
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
}
