{ config, lib, pkgs, ... }:

with lib;
let 
  cfg = config.programs.neofetch;

  shellCommand = "${cfg.package}/bin/neofetch";
in {
  meta.maintainers = [ wolfangaukang ];

  options.programs.neofetch = {
    enable = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Installs Neofetch
      '';
    };
    package = mkOption {
      default = pkgs.neofetch;
      type = types.package;
      description = ''
        The Neofetch package to install
      '';
    }; 
    startOnBash = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Adds neofetch to BASH profile
      '';
    };
    startOnZsh = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Adds neofetch to ZSH profile
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [ cfg.package ];
      programs = {
        bash.initExtra = mkIf cfg.startOnBash ''
          ${shellCommand}
        '';
        zsh.initExtra = mkIf cfg.startOnZsh ''
          ${shellCommand}
        '';
      };
    }
  ]);
}
