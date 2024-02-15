{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.waybar;
in
{
  sane.programs.waybar = {
    configOption = with lib; mkOption {
      type = types.submodule {
        options = {
          extra_style = mkOption {
            type = types.lines;
            default = ''
              /* default font-size is about 14px, which is good for moby, but not quite for larger displays */
              window#waybar {
                font-size: 16px;
              }
            '';
            description = ''
              extra CSS rules to append to ~/.config/waybar/style.css
            '';
          };
          top = mkOption {
            type = types.submodule {
              # `attrsOf types.anything` (v.s. plain `attrs`) causes merging of the toplevel items.
              # this allows for `waybar.top.x = lib.mkDefault a;` with `waybar.top.x = b;` to resolve to `b`.
              # but note that `waybar.top.x.y = <multiple assignment>` won't be handled as desired.
              freeformType = types.attrsOf types.anything;
            };
            default = {};
            description = ''
              Waybar configuration for the bar at the top of the display.
              see: <https://github.com/Alexays/Waybar/wiki/Configuration>
              example:
              ```nix
              {
                height = 40;
                modules-left = [ "sway/workspaces" "sway/mode" ];
                ...
              }
              ```
            '';
          };
        };
      };
    };

    # default waybar
    config.top = import ./waybar-top.nix { inherit lib pkgs; };

    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.net = "all";  #< to show net connection status and BW
    sandbox.whitelistDbus = [ "user" ];
    sandbox.whitelistWayland = true;
    sandbox.extraRuntimePaths = [ "/" ];  #< needs to talk to sway IPC. TODO: give the sway IPC a predictable name.

    fs.".config/waybar/config".symlink.target =
      (pkgs.formats.json {}).generate "waybar-config.json" [
        ({ layer = "top"; } // cfg.config.top)
      ];
    fs.".config/waybar/style.css".symlink.text =
      (builtins.readFile ./waybar-style.css) + cfg.config.extra_style;

    services.waybar = {
      description = "sway header bar";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig.ExecStart = "${cfg.package}/bin/waybar";
      serviceConfig.Type = "simple";
      serviceConfig.Restart = "on-failure";
      serviceConfig.RestartSec = "10s";
      # environment.G_MESSAGES_DEBUG = "all";
    };
  };
}
