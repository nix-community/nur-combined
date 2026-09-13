{
  flake.modules.nixos.clickhouse =
    { config, ... }:
    {
      services.clickhouse = {
        enable = true;
      };

      environment.etc."clickhouse-server/config.d/200-backup-config.xml".source =
        config.vaultix.secrets.clickhouse-backup.path;
      environment.etc."clickhouse-server/config.d/100-listen-config.xml".text = ''
        <clickhouse>
            <listen_host>::</listen_host>
        </clickhouse>
      '';

      systemd.services.clickhouse.wants = [ "var-lib-clickhouse.mount" ];
      vaultix.secrets = {
        "clickhouse-backup" = {
          owner = "clickhouse";
        };
      };
    };
}
