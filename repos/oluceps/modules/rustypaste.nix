{ pkgs
, config
, lib
, ...
}:
with lib;
let
  cfg = config.services.rustypaste;
  settingsFormat = pkgs.formats.toml { };
in
{
  options.services.rustypaste = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    package = mkOption {
      type = types.package;
      default = pkgs.rustypaste;
    };
    settings = mkOption {
      inherit (settingsFormat) type;
      default = { };
    };
  };
  config =
    mkIf cfg.enable {
      systemd.services.rustypaste = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        description = "pastebin";

        serviceConfig = {
          Type = "simple";
          ExecStart = "${cfg.package}/bin/rustypaste";
          StateDirectory = "paste";
          Environment = "CONFIG=${settingsFormat.generate "config.toml" cfg.settings}";
          Restart = "on-failure";
        };
      };
    };
}
