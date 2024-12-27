{ self }:
{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.services.linguee-api;
in {
  options.services.linguee-api = {
    enable = mkEnableOption "Linguee API proxy service to convert HTML responses from linguee.com to JSON format";

    package = mkOption {
      type = types.package;
      default = self.linguee-api-server;
      defaultText = "pkgs.nur.repos.andreasrid.linguee-api-server";
      description = "Set version of Linguee-API package to use.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.linguee-api = {
      description = "Linguee API proxy";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      restartIfChanged = true;
      serviceConfig = {
        DynamicUser = true;
        RuntimeDirectory = "linguee-api";
        ExecStart = pkgs.lib.getExe cfg.package;
        Restart = "always";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [  ];
}
