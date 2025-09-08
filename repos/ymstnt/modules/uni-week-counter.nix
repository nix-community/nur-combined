{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    ;
  inherit (lib.types)
    port
    str
    package
    ;

  user = "uni-week-counter";
  cfg = config.uni-week-counter;
in
{
  options.uni-week-counter = {
    enable = mkEnableOption "Enable the Uni Week Counter service";
    package = mkOption {
      type = package;
      default = pkgs.callPackage ../pkgs/uni-week-counter { };
    };
    group = mkOption {
      type = str;
      description = ''
        The group for uni-week-counter user that the systemd service will run under.
      '';
    };
    port = mkOption {
      type = port;
      default = 8080;
      description = ''
        The port the API will be accessible on.
      '';
    };
  };

  config = mkIf cfg.enable {
    users.users.uni-week-counter = {
      isSystemUser = true;
      createHome = true;
      group = cfg.group;
    };

    systemd.services.uni-week-counter = {
      description = "University week counter API.";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/uni-week-counter";
        User = user;
        Group = cfg.group;
        Environment = "PORT=${toString cfg.port}";
      };
    };
  };
}

