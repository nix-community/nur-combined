{
  reIf,
  ...
}:
reIf {
  postgresqlBackup = {
    enable = true;
    location = "/var/lib/backup/postgresql";
    compression = "zstd";
    startAt = "*-*-* 0,12:00:00";
  };
}
