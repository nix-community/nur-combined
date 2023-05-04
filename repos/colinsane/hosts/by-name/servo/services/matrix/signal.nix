# config options:
# - <https://github.com/mautrix/signal/blob/master/mautrix_signal/example-config.yaml>
{ config, pkgs, ... }:
{
  sane.persist.sys.plaintext = [
    { user = "mautrix-signal"; group = "mautrix-signal"; directory = "/var/lib/mautrix-signal"; }
    { user = "signald"; group = "signald"; directory = "/var/lib/signald"; }
  ];

  # allow synapse to read the registration file
  users.users.matrix-synapse.extraGroups = [ "mautrix-signal" ];

  services.signald.enable = true;
  services.mautrix-signal.enable = true;
  services.mautrix-signal.environmentFile =
    config.sops.secrets.mautrix_signal_env.path;

  services.mautrix-signal.settings.signal.socket_path = "/run/signald/signald.sock";
  services.mautrix-signal.settings.homeserver.domain = "uninsane.org";
  services.mautrix-signal.settings.bridge.permissions."@colin:uninsane.org" = "admin";
  services.matrix-synapse.settings.app_service_config_files = [
    # auto-created by mautrix-signal service
    "/var/lib/mautrix-signal/signal-registration.yaml"
  ];

  systemd.services.mautrix-signal.serviceConfig = {
    # allow communication to signald
    SupplementaryGroups = [ "signald" ];
    ReadWritePaths = [ "/run/signald" ];
  };

  sops.secrets."mautrix_signal_env" = {
    mode = "0440";
    owner = config.users.users.mautrix-signal.name;
    group = config.users.users.matrix-synapse.name;
  };
}
