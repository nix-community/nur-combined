{
  flake.modules.nixos.mysql =
    { pkgs, ... }:
    {
      services.mysql = {
        enable = true;
        package = pkgs.mariadb_114;
        dataDir = "/var/lib/mysql";
      };
    };
}
