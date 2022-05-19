{ pkgs, lib, config, options, ... }:
with lib;

let
  cfg = config.services.bazarr;

in
{
  options = {
    services.bazarr = {
      package = mkOption {
        type = types.package;
        default = pkgs.bazarr;
        defaultText = literalExpression "pkgs.bazarr";
        description = "Bazarr package to use";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.bazarr = {
      description = mkForce "Bazarr";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "bazarr";
        SyslogIdentifier = "bazarr";
        ExecStart = mkForce "${cfg.package}/bin/bazarr --config '/var/lib/bazarr' --port ${toString cfg.listenPort} --no-update True";
        Restart = "on-failure";
      };
    };
  };
}
