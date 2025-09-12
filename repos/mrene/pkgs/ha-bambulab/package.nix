{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
}:

buildHomeAssistantComponent rec {
  pname = "ha-bambulab";
  version = "2.2.1";

  owner = "greghesp";
  domain = "bambu_lab";

  src = fetchFromGitHub {
    owner = "greghesp";
    repo = "ha-bambulab";
    rev = "v${version}";
    hash = "sha256-D/HAjVTpdoh9jWT8LOm5d/e6OSR5to/oW9YKNOu60ms=";
  };

  dependencies = with home-assistant.python.pkgs; [
    beautifulsoup4
  ];

  meta = {
    description = "A Home Assistant Integration for Bambu Lab Printers";
    homepage = "https://github.com/greghesp/ha-bambulab/";
    maintainers = with lib.maintainers; [ mrene  ];
    mainProgram = "ha-bambulab";
    platforms = lib.platforms.linux;
  };
}
