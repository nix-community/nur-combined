# config options:
# - <https://github.com/mautrix/signal/blob/master/mautrix_signal/example-config.yaml>
{ config, lib, pkgs, ... }:

lib.mkIf false  # disabled 2024/01/11: i don't use it, and pkgs.mautrix-signal had some API changes
{
  sane.persist.sys.byStore.plaintext = [
    { user = "mautrix-signal"; group = "mautrix-signal"; path = "/var/lib/mautrix-signal"; method = "bind"; }
    { user = "signald"; group = "signald"; path = "/var/lib/signald"; method = "bind"; }
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
