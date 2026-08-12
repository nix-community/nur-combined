{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dir2opds;
  nurpkgs = pkgs.nur.repos.wariuccio;
in
{
  options.services.dir2opds = {
    enable = lib.mkEnableOption "dir2opds";
    package = lib.mkPackageOption nurpkgs "dir2opds" { };
  };
  config.systemd.services.dir2opds = lib.mkIf cfg.enable {
    description = "dir2opds";
    wantedBy = [ "multi-user.target" ];
    environment = { };
    serviceConfig = {
      ExecStart = "${lib.getExe cfg.package} -dir /var/lib/dir2opds/ -port 3005";
      User = "dir2opds";
      Group = "dir2opds";
      StateDirectory = "dir2opds";
      StateDirectoryMode = "0770";
      Restart = "on-failure";
    };
  };
  config.users = {
    extraUsers.dir2opds = {
      isSystemUser = true;
      group = "dir2opds";
    };
    groups.dir2opds = { };
  };
}
