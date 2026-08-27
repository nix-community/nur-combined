{
  flake.modules.nixos.clickhouse =
    { config, ... }:
    {
      services.clickhouse = {
        enable = true;
      };

      environment.etc."clickhouse-server/config.d/200-backup-config.xml".source =
        config.vaultix.secrets.clickhouse-backup.path;

      vaultix.secrets = {
        "clickhouse-backup" = {
          owner = "clickhouse";
        };
      };
    };
}
