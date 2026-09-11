{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent {
  owner = "shirok1";
  domain = "zhejiang_typhoon";
  version = "0.1.0-unstable";

  src = fetchFromGitHub {
    owner = "shirok1";
    repo = "hass-zhejiang-typhoon";
    rev = "832a9b3543cb73908b0e4a6ec9e3d0180fae3d04";
    hash = "sha256-XJS2St5au+aOICpiu+z7gWmlnG5xNwlG7AFQlq2+Uco=";
  };

  meta = {
    description = "Home Assistant integration tracking all active typhoons from the Zhejiang Water Resources Department public typhoon-track system as geo_location entities";
    homepage = "https://github.com/shirok1/hass-zhejiang-typhoon";
    license = lib.licenses.mit;
  };
}
