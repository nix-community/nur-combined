{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.vlmcsd;
in
{

  options.services.vlmcsd = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable vlmcsd service.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.nur.repos.linyinfeng.vlmcsd;
      defaultText = "pkgs.nur.repos.linyinfeng.vlmcsd";
      description = ''
        vlmcsd derivation to use.
      '';
    };

    extraOptions = mkOption {
      type = types.separatedString " ";
      default = "";
      example = "-L 0.0.0.0:1688 -L [::]:1688";
      description = ''
        extra command line options for vlmcsd service.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    systemd.services.vlmcsd =
      {
        description = "KMS Emulator";

        serviceConfig = {
          Type = "forking";
          User = "nobody";
          ExecStart = "${cfg.package}/bin/vlmcsd ${cfg.extraOptions}";
        };

        wantedBy = [ "multi-user.target" ];
      };

    environment.systemPackages = [
      cfg.package
    ];
  };
}
