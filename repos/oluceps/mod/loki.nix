{
  flake.modules.nixos.loki =
    { config, ... }:
    {
      vaultix.secrets.loki = {
        owner = config.services.loki.user;
        group = config.services.loki.group;
        mode = "400";
      };
      services.loki = {
        enable = true;
        configFile = config.vaultix.secrets.loki.path;
      };
    };
}
