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
      ## subset of default_config
      "file"
      "history"
      # "homeassistant_alerts"
      "logbook"
      "mobile_app"
      "my"
      "sun"
      # "usage_prediction"
      # "webhook"
      ## extra
      # "command_line"
      "template"
      "profiler"
    ];
    customComponents =
      (with pkgs.home-assistant-custom-components; [
        midea_ac_lan
      ])
      ++ (with pkgs; [ home-assistant-heweather ]);
  };
  services.home-assistant.config = {
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
