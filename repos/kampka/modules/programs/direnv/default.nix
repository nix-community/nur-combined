{ config, lib, pkgs, ... }:

with lib;
let

  cfg = config.kampka.programs.direnv;

in
{

  options.kampka.programs.direnv = {
    enable = mkEnableOption "direnv - environment switcher for the shell";

    configureBash = mkOption {
      type = types.bool;
      default = false;
      description = "Whether or not to enable bash configuration.";
    };

    configureZsh = mkOption {
      type = types.bool;
      default = config.programs.zsh.enable;
      description = "Whether or not to enable zsh configuration.";
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.direnv ];

    programs.bash.interactiveShellInit = mkIf cfg.configureBash ''
      eval "$(${pkgs.direnv}/bin/direnv hook bash)"
    '';

    programs.zsh.interactiveShellInit = mkIf cfg.configureZsh ''
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
    '';
  };
}
