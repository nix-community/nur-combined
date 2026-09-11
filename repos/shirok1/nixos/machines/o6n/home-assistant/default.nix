{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./airengine.nix
    ./ir.nix
  ];

  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"

      "apple_tv"
      "bthome"
      "esphome"
      "homekit"
      "homekit_controller"
      "mqtt"
      "mqtt_eventstream"
      "mqtt_json"
      "mqtt_room"
      "mqtt_statestream"
      "nintendo_parental_controls"
      "openai_conversation"
      "open_router"
      "ping"
      "qbittorrent"
      "sleep_as_android"
      "snmp"
      "sonos"
      "steam_online"
      "systemmonitor"
      "tasmota"
      "thread"
      "upnp"
      "waqi"
      "xiaomi_ble"

      "kegtron"
      "ibeacon"

      "ffmpeg"
      "zeroconf"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
      "script ui" = "!include scripts.yaml";

      homeassistant = {
        external_url = "https://ha.berry.shiroki.tech";
      };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
      };

      template = lib.mkAfter [ ];
    };
    customComponents = with pkgs.home-assistant-custom-components; [
      pkgs.shirok1.hasscc-tianqi
      pkgs.shirok1.hass-xiaomi-weather
      pkgs.shirok1.hass-zhejiang-typhoon
      (pkgs.shirok1.tasmota-irhvac.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "hristo-atanasov";
          repo = "Tasmota-IRHVAC";
          rev = "pull/190/head";
          hash = "sha256-HlVUVbtbrCFWFlrVtQ+UqET+VpN9fpN261c8OkG1jZU=";
        };
      }))
      (xiaomi_home.overrideAttrs (oldAttrs: {
        # src = inputs.ha-xiaomi-home;
        src = pkgs.fetchFromGitHub {
          owner = "XiaoMi";
          repo = "ha_xiaomi_home";
          rev = "pull/1658/head";
          hash = "sha256-DSPNI/o9P2fu7UgbVvEtv7Uj77p5g5xCgAlFTolh/0o=";
        };
      }))
      pkgs.shirok1.zuyan9-ha-cuk-ble
    ];
  };
  sops.secrets."snmp/auth_key" = { };
  sops.secrets."snmp/priv_key" = { };
  sops.templates."hass.env".content = ''
    HUAWEI_AP_SNMP_USERNAME=hass
    HUAWEI_AP_SNMP_AUTH_KEY=${config.sops.placeholder."snmp/auth_key"}
    HUAWEI_AP_SNMP_PRIV_KEY=${config.sops.placeholder."snmp/priv_key"}
  '';
  systemd.services.home-assistant = {
    serviceConfig = {
      Environment = [
        "OPENAI_BASE_URL=https://api.deepseek.com/v1"
      ];
      EnvironmentFile = [ config.sops.templates."hass.env".path ];
    };
  };

}
