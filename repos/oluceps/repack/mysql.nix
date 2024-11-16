{ reIf, pkgs, ... }:
reIf {
  services.mysql = {
    enable = true;
    package = pkgs.mariadb_1011;
    dataDir = "/var/lib/mysql";
  };
}
