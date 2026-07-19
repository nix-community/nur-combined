{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.sops) secrets;
in
{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "command_line"
      "template"
      "google_translate"
    ];
    customComponents = with pkgs.home-assistant-custom-components; [
      midea_ac_lan
    ];
  };
  services.home-assistant.config = {
    default_config = { };
    "automation ui" = "!include automations.yaml";
    "scene ui" = "!include scenes.yaml";
    "script ui" = "!include scripts.yaml";
  };

  services.home-assistant.package =
    (pkgs.home-assistant.overrideAttrs (_: {
      doInstallCheck = false;
    })).override
      {
        packageOverrides = final: prev: {
          paho-mqtt = prev.paho-mqtt.overridePythonAttrs {
            doCheck = false;
          };
        };
      };

}
