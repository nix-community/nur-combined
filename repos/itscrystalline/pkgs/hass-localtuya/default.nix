{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:
buildHomeAssistantComponent rec {
  owner = "xZetsubou";
  domain = "localtuya";
  version = "2025.11.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = domain;
    rev = version;
    hash = "sha256-TISiZchkLZ3AaNh622nolIyBjDgdJBQrc30oBHN/INE=";
  };

  passthru.isHomeAssistantComponent = true;

  meta = with lib; {
    changelog = "https://github.com/xZetsubou/hass-localtuya/releases/tag/${version}";
    description = "Home Assistant custom Integration for local handling of Tuya-based devices";
    homepage = "https://github.com/xZetsubou/hass-localtuya";
    maintainers = [];
    license = licenses.gpl3Only;
    sourceProvenance = [sourceTypes.fromSource];
  };
}
