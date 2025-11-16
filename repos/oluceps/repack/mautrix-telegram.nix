{ reIf, config, ... }:
reIf {

  systemd.services = {
    mautrix-telegram.serviceConfig.RuntimeMaxSec = 86400;
  };

  services.mautrix-telegram = {
    enable = true;
    environmentFile = config.vaultix.secrets.mautrix-tg.path;
    serviceDependencies = [ "matrix-synapse.service" ];
    settings = {
      homeserver = {
        address = "http://[fdcc::3]:8196";
        domain = "nyaw.xyz";
      };
      appservice = {
        address = "http://127.0.0.1:29317";
        database = "postgres:///mautrix-telegram?host=/run/postgresql";
        hostname = "127.0.0.1";
        port = 29317;
        provisioning.enabled = false;
      };
      bridge = {
        displayname_template = "{displayname}";
        public_portals = true;
        delivery_error_reports = true;
        incoming_bridge_error_reports = true;
        bridge_matrix_leave = false;
        relay_user_distinguishers = [ ];
        create_group_on_invite = false;
        animated_sticker = {
          target = "webp";
          convert_from_webm = true;
        };
        state_event_formats = {
          join = "";
          leave = "";
          name_change = "";
        };
        permissions = {
          "*" = "relaybot";
          "@sec:nyaw.xyz" = "admin";
          "@lyo:nyaw.xyz" = "admin";
        };
        relaybot = {
          authless_portals = false;
          ignore_unbridged_group_chat = true;
        };
      };
      telegram = {
        api_id = 611335;
        api_hash = "d524b414d21f4d37f08684c1df41ac9c";
        device_info = {
          app_version = "3.5.2";
        };
        force_refresh_interval_seconds = 3600;
      };
      logging = {
        loggers = {
          mau.level = "WARNING";
          telethon.level = "WARNING";
        };
      };
    };
  };
}
