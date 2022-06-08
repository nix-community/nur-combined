{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.nix-index;
in {
  options.programs.nix-index = {
    enable = mkEnableOption "command-not-found replacement";
  };

  config = mkIf cfg.enable {
    programs.command-not-found.enable = false;

    environment.systemPackages = with pkgs; [ nix-index ];

    programs.bash.interactiveShellInit = ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
    '';

    programs.zsh.interactiveShellInit = ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
    '';

    programs.fish.interactiveShellInit = let
      wrapper = pkgs.writeScript "command-not-found" ''
        #!${pkgs.bash}/bin/bash
        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
        command_not_found_handle "$@"
      '';
    in ''
      function __fish_command_not_found_handler --on-event fish_command_not_found
          ${wrapper} $argv
      end
    '';
  };
}
