{ reIf, pkgs, ... }:
reIf {
  services.mysql = {
    enable = true;
    package = pkgs.mariadb_114;
    dataDir = "/var/lib/mysql";
  };
}
