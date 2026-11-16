{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  owner = "derspe";
  domain = "easy_stock";
  version = "v0.5.1";

  src = fetchFromGitHub {
    owner = owner;
    repo = "ha-easy-stock";
    rev = "62b26666cecf61f179c47b13cb976b46365d946c";
    hash = "sha256-Em2SPFBnjZhuWcJ0InAjr+zqjIi7pADPHN6joVv+OX8=";
  };

  meta = {
    description = "Yahoo Finance stock/ETF/crypto tracker for Home Assistant";
    homepage = "https://github.com/derspe/ha-easy-stock";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      zeal
    ];
  };
}
