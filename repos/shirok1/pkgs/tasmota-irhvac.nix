{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent rec {
  owner = "hristo-atanasov";
  domain = "tasmota_irhvac";
  version = "2026.04.05";

  src = fetchFromGitHub {
    owner = "hristo-atanasov";
    repo = "Tasmota-IRHVAC";
    rev = "v${version}";
    hash = "sha256-aFnyar2R0ibkLfJh9UgR899lQ9iLSufsDuX33Al3UiU=";
  };

  meta = {
    description = "Home Assistant platform for controlling IR Air Conditioners via Tasmota IRHVAC command and compatible hardware";
    homepage = "https://github.com/hristo-atanasov/Tasmota-IRHVAC/";
    license = lib.licenses.asl20;
  };
}
