{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.gost;
  settingsFormat = pkgs.formats.json { };
in
{
  options = {
    services.gost = {
      enable = lib.mkEnableOption "A simple security tunnel written in Golang";

      package = lib.mkPackageOption pkgs "gost" { };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = settingsFormat.type;
          options = { };
        };
        default = { };
        description = lib.mdDoc ''
          The gost configuration, see https://v2.gost.run/ for documentation.

          Options containing secret data should be set to an attribute set
          containing the attribute `_secret` - a string pointing to a file
          containing the value the option should be set to.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.packages = [ cfg.package ];

    systemd.services.gost = {
      preStart = ''
        umask 0077
        mkdir -p /etc/gost
        ${utils.genJqSecretsReplacementSnippet cfg.settings "/etc/gost/config.json"}
      '';
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/gost -C /etc/gost/config.json";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
