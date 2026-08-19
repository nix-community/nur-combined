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
    getExe
    ;
  cfg = config.abszero.services.displayManager.tuigreet;

  format = pkgs.formats.toml { };
in

{
  options.abszero.services.displayManager.tuigreet = {
    enable = mkEnableOption "TUI greetd frontend";
    # TODO: use nixpkgs option when supported
    settings = mkOption {
      type = format.type;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    abszero.services.displayManager.tuigreet.settings = {
      display = {
        show_time = true;
        battery = true;
      };
      session.sessions_dirs = [ "/run/current-system/sw/share/wayland-sessions" ];
      remember = {
        username = true;
        user_session = true;
      };
      power = {
        shutdown = "systemctl poweroff";
        reboot = "systemctl reboot";
        suspend = "systemctl suspend";
        hibernate = "systemctl hibernate";
      };
      secret.mode = "characters";
      layout.window_padding = 1;
    };

    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings.default_session.command = getExe pkgs.tuigreet;
    };

    environment = {
      # Somehow this is not done by default
      pathsToLink = [ "/share/wayland-sessions" ];
      etc."tuigreet/config.toml".source = format.generate "tuigreet-config.toml" cfg.settings;
    };
  };
}
