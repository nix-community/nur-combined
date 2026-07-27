{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.gosmee;
in
{
  options = {
    services.gosmee = {
      enable = mkEnableOption ''
        gosmee is a webhook forwader/relayer
      '';
      package = mkOption {
        type = types.package;
        default = pkgs.gosmee;
        description = ''
          gosmee package to use.
        '';
      };

      public-url = mkOption {
        description = ''
          Public URL to show to user, useful when you are behind a proxy.
        '';
        type = types.str;
        default = "";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.packages = [ cfg.package ];
    systemd.services.gosmee = {
      description = "Gosmee service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        # User = cfg.user;
        Restart = "on-failure";
        ExecStart = ''
          ${cfg.package}/bin/gosmee server \
          ${optionalString (cfg.public-url != "") "--public-url ${escapeShellArg cfg.public-url}"}
        '';
      };
      path = [ cfg.package ];
    };
  };
}

