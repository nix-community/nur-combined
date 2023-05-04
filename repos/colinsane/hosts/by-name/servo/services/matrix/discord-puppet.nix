{ lib, ... }:
{
  sane.persist.sys.plaintext = [
    { user = "matrix-synapse"; group = "matrix-synapse"; directory = "/var/lib/mx-puppet-discord"; }
  ];

  services.matrix-synapse.settings.app_service_config_files = [
    # auto-created by mx-puppet-discord service
    "/var/lib/mx-puppet-discord/discord-registration.yaml"
  ];

  services.mx-puppet-discord.enable = true;
  # schema/example: <https://gitlab.com/mx-puppet/discord/mx-puppet-discord/-/blob/main/sample.config.yaml>
  services.mx-puppet-discord.settings = {
    bridge = {
      # port = 8434
      bindAddress = "127.0.0.1";
      domain = "uninsane.org";
      homeserverUrl = "http://127.0.0.1:8008";
      # displayName = "mx-discord-puppet";  # matrix name for the bot
      # matrix "groups" were an earlier version of spaces.
      # maybe the puppet understands this, maybe not?
      enableGroupSync = false;
    };
    presence = {
      enabled = false;
      interval = 30000;
    };
    provisioning = {
      # allow these users to control the puppet
      whitelist = [ "@colin:uninsane\\.org" ];
    };
    relay = {
      whitelist = [ "@colin:uninsane\\.org" ];
    };
    selfService = {
      # who's allowed to use plumbed rooms (idk what that means)
      whitelist = [ "@colin:uninsane\\.org" ];
    };
    logging = {
      # silly, debug, verbose, info, warn, error
      console = "debug";
    };
  };

  # TODO: should use a dedicated user
  systemd.services.mx-puppet-discord.serviceConfig = {
    # fix up to not use /var/lib/private, but just /var/lib
    DynamicUser = lib.mkForce false;
    User = "matrix-synapse";
    Group = "matrix-synapse";
  };
}
