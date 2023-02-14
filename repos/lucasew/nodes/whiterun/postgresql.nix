{ ... }:
{
  services.postgresql = {
    enable = true;
  };
  services.postgresqlBackup = {
    enable = true;
    databases = [ "postgres" ];
  };
}
