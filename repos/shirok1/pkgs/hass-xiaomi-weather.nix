{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent {
  owner = "shirok1";
  domain = "xiaomi_weather";
  version = "0.1.0-unstable";

  src = fetchFromGitHub {
    owner = "shirok1";
    repo = "hass-xiaomi-weather";
    rev = "bc119fff7deeb13d59cfedcf72eedf08ba726ec7";
    hash = "sha256-X4Alinka+ldcrFZdy2bEz+MKjcJ1gCuiX2D7NbeZHls=";
  };

  meta = {
    description = "Xiaomi Weather integration for Home Assistant: current conditions, daily/hourly forecasts and China AQI/PM2.5/PM10 sensors via the Xiaomi weather cloud API, configurable through the UI";
    homepage = "https://github.com/shirok1/hass-xiaomi-weather";
    license = lib.licenses.mit;
  };
}
