{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.kampka.services.tmux;

  tmuxConfig = pkgs.writeText "tmux.conf" ''
    ${optionalString (cfg.configurePowerline) ''
    # Source the powerline shell configuration
    source "${cfg.powerlinePackage}/share/tmux/powerline.conf"
  '' }

    # Keep tmux alive even if there is no active session left
    set -g exit-empty off
    set -g exit-unattached off
    set -g destroy-unattached off

    # Update the PATH to prevent the daemon path from leaking through
    set -g update-environment ' PATH'

    ${optionalString (cfg.zshAutoConfigure) ''
    # Configure zsh as default shell
    set-option -g default-shell ${pkgs.zsh}/bin/zsh
    set-option -g default-command ${pkgs.zsh}/bin/zsh
  ''}


    # Source users tmux.conf
    if-shell "test -e $HOME/.tmux.conf" 'source "$HOME/.tmux.conf"'
  '';

  tmuxStarter = "${lib.readFile ./tmux-starter}";
in
{

  options.kampka.services.tmux = {
    enable = mkEnableOption "tmux user service";

    configurePowerline = mkOption {
      type = types.bool;
      default = true;
      description = "Whether or not to enable powerline for tmux.";
    };

    powerlinePackage = mkOption {
      type = types.package;
      default = pkgs.python3Packages.powerline;
      description = "The powerline package to install";
    };

    sessionName = mkOption {
      type = types.string;
      default = "default";
      description = "The name of the tmux session to spawn.";
    };

    zshAutoConfigure = mkOption {
      type = types.bool;
      default = config.programs.zsh.enable;
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.tmux ];

    programs.zsh.interactiveShellInit = mkIf cfg.zshAutoConfigure ''
      ${tmuxStarter}
    '';
    systemd.user.services.tmux = {
      description = "tmux terminal multiplexer";

      unitConfig = {
        ConditionUser = "!@system";
      };

      serviceConfig = {
        Type = "forking";
        ExecStart = "${pkgs.tmux}/bin/tmux -f ${tmuxConfig} start-server";
        ExecStop = "${pkgs.tmux}/bin/tmux kill-server";
        Restart = "always";
        RemainAfterExit = true;
      };
      wantedBy = [ "default.target" ];

      path = [ pkgs.tmux cfg.powerlinePackage ];
    };
  };
}
