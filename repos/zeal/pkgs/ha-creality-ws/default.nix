{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-assistant,
}:

buildHomeAssistantComponent rec {
  owner = "3dg1luk43";
  domain = "ha_creality_ws";
  version = "0.9.10";

  src = fetchFromGitHub {
    inherit owner;
    repo = "ha_creality_ws";
    rev = "58c00818e8303a0d636bd05929cad215aed9ccb3";
    hash = "sha256-1L5LZ9lcsK1yjcmBOjoJyypkDTkdKdbvVz2jTHT4W2M=";
  };

  dependencies = with home-assistant.python3Packages; [
    websockets
    go2rtc-client
  ];

  meta = {
    description = "Local WebSocket integration for Creality 3D printers";
    homepage = "https://github.com/3dg1luk43/ha_creality_ws";
    license = with lib.licenses; [
      agpl3Only
      # unfree
    ];
    maintainers = with lib.maintainers; [ zeal ];
  };
}
