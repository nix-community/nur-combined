{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-assistant,
}:

buildHomeAssistantComponent rec {
  owner = "TheFab21";
  domain = "denon_marantz_avr";
  version = "1.10.2";

  src = fetchFromGitHub {
    owner = "TheFab21";
    repo = "ha-denon-marantz-avr";
    tag = "v${version}";
    hash = "sha256-Lgcf8ne7vLZqxh63XWTWJgcc8HPLcnz6iorHvXQyPv4=";
  };

  dependencies = with home-assistant.python3Packages; [
    denonavr
    pyheos
  ];

  meta = {
    description = "Denon & Marantz AVR integration for Home Assistant with Audyssey, sound mode, channel volume and HEOS controls";
    homepage = "https://github.com/TheFab21/ha-denon-marantz-avr";
    changelog = "https://github.com/TheFab21/ha-denon-marantz-avr/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mrene ];
  };
}
