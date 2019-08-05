{ pkgs, config, lib, ... }: with lib; let
  cfg = config.services.filebin;
in {
  options.services.filebin = {
    enable = mkEnableOption "filebin path monitor";

    path = mkOption {
      type = types.path;
      default = "/run/filebin";
    };

    user = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    notify = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.filebin = {
      description = "filebin automatic uploads";
      after = ["network.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart= "${pkgs.arc'private.filebin.exec} ${if cfg.notify then "-n" else ""} -d ${cfg.path}";
        User = mkIf (cfg.user != null) cfg.user;
      };
    };
    systemd.paths.filebin = {
      description = "filebin automatic uploads";
      pathConfig = {
        DirectoryNotEmpty = cfg.path;
        MakeDirectory = true;
        DirectoryMode = "0777";
      };
      wantedBy = ["multi-user.target"];
    };
  };
}
