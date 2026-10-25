{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.t3code;
  user = config.users.users.avy;
in
{
  options.homelab.services.t3code = {
    enable = lib.mkEnableOption "T3 Code headless coding-agent server for avy";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3773;
      description = "Local port for the T3 Code server (access via an SSH tunnel)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Use Home Manager's program module for the package and user configuration.
    # Its mutable settings, keybindings and client settings retain their defaults.
    home-manager.users.avy.programs.t3code.enable = true;

    assertions = [
      {
        assertion = config.home-manager.users.avy.programs.t3code.package != null;
        message = "homelab.services.t3code requires a T3 Code package in Home Manager";
      }
    ];

    # The locked Home Manager module installs/configures T3 Code but does not
    # provide a server unit. Run the headless binary as the same user so it
    # reads the mutable files under ~/.t3/userdata.
    systemd.services.t3code = {
      description = "T3 Code headless server";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network-online.target"
        "tailscaled.service"
      ];
      wants = [
        "network-online.target"
        "tailscaled.service"
      ];
      path = [ pkgs.tailscale ];
      serviceConfig = {
        Type = "exec";
        User = "avy";
        WorkingDirectory = user.home;
        ExecStart = "${lib.getExe' config.home-manager.users.avy.programs.t3code.package "t3"} serve --port ${toString cfg.port} --tailscale-serve";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      unitConfig.OnFailure = lib.mkIf (
        config.homelab.notifications.ntfySecretsFile != null
      ) "notify-failure@%n.service";
    };
  };
}
