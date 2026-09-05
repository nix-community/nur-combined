{
  flake.modules.nixos.clickhouse =
    { config, ... }:
    {
      services.clickhouse = {
        enable = true;
      };

      environment.etc."clickhouse-server/config.d/200-backup-config.xml".source =
        config.vaultix.secrets.clickhouse-backup.path;

      systemd.services.clickhouse.wants = [ "var-lib-clickhouse.mount" ];
      vaultix.secrets = {
        "clickhouse-backup" = {
          owner = "clickhouse";
        };
      };
    };
}
