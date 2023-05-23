{ config, pkgs, lib, materusFlake, materusPkgs, ... }:
let
  profile = config.materus.profile;
  cfg = config.materus.profile.starship;
in
{
  options.materus.profile.starship.enable = materusPkgs.lib.mkBoolOpt (profile.zsh.enable || profile.bash.enable || profile.fish.enable) "Enable materus fish config";

  config = lib.mkIf cfg.enable {
    programs.starship.enable = lib.mkDefault cfg.enable;

    programs.starship.settings = {

      python = {
        symbol = " ";
      };

      format = "$username@$hostname$all";
      right_format = "$cmd_duration $time";
      
      time = {
        disabled = false;
        style = "bold bright-black";
        format = "[$time]($style)";
      };

      line_break = { disabled = true; };
      shell = {
        disabled = false;
        fish_indicator = "fish";
        bash_indicator= "bash";
        zsh_indicator= "zsh";
        style = "blue bold";
      };

      hostname = {
        ssh_only = false;
      };
      username = {
        disabled = false;
        show_always = true;
        format = "[$user]($style)";
        style_user = "white bold";
        style_root = "black bold";
      };
    };
  };
}
