# Home Manager / NixOS shared module: magpie tray app auto-start
{
  config,
  lib,
  options,
  ...
}:

let
  cfg = config.services.magpie;
in
{
  options.services.magpie = {
    enable = lib.mkEnableOption "magpie - local AI model gateway (tray app)";

    package = lib.mkOption {
      type = lib.types.package;
      example = lib.literalExpression "pkgs.magpie";
      description = "The magpie package to use.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        systemd.user.services.magpie = {
          Unit = {
            Description = "magpie - local AI model gateway (tray app)";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${lib.getExe cfg.package} tray";
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      }
      # Install the package into the user profile when imported as a
      # Home Manager module, or the system profile for NixOS.
      (lib.optionalAttrs (options ? home.packages) {
        home.packages = [ cfg.package ];
      })
      (lib.optionalAttrs (options ? environment) {
        environment.systemPackages = [ cfg.package ];
      })
    ]
  );
}
