{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "shirok1";
  domain = "lumi_curtain";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "shirok1";
    repo = "hass-lumi-curtain";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9/G/iGxt435hIXtx5F2tNN3RVT13+vKkNq9/6kV/DxM=";
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
