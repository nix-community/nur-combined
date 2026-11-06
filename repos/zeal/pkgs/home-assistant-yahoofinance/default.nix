{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  owner = "iprak";
  domain = "yahoofinance";
  version = "v1.5.5";

  src = fetchFromGitHub {
    owner = owner;
    repo = domain;
    rev = "760659d2aea38908e5f3e75d433e53f7370a0b93";
    hash = "sha256-E2T4wdAWVnULXfVCsKer3P/DrCrqUbsbYh984PNZ1/E=";
  };

  meta = {
    description = "Custom component for Home Assistant that integrates stock updates from Yahoo finance";
    homepage = "https://github.com/iprak/yahoofinance";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      zeal
    ];
  };
}
