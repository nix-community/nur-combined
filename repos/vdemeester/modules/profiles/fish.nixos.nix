{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.fish;
in
{
  options = {
    profiles.fish = {
      enable = mkOption {
        default = false;
        description = "Enable fish profile";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      promptInit = ''
        source /etc/fish/functions/fish_prompt.fish
        source /etc/fish/functions/fish_right_prompt.fish
      '';
    };
    environment.etc."fish/functions/fish_prompt.fish".source = ./assets/fish/fish_prompt.fish;
    environment.etc."fish/functions/fish_right_prompt.fish".source = ./assets/fish/fish_right_prompt.fish;
  };
}
