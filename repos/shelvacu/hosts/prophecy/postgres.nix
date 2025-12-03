{ pkgs, config, ... }:
{
  vacu.packages = [ config.services.postgresql.package ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    identMap = ''
      postgres root postgres
    '';
    initdbArgs = [ "--data-checksums" ];
    enableTCPIP = false;
    # settings.port = 5432;
  };
}
