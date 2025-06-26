{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf removePrefix;
  cfg = config.abszero.programs.zsh;
in

{
  options.abszero.programs.zsh.enable = mkEnableOption "Z shell";

  config.programs.zsh = mkIf cfg.enable {
    enable = true;
    # Hack since `dotDir` is relative to home
    dotDir = "${removePrefix "${config.home.homeDirectory}/" config.xdg.configHome}/zsh";
    autocd = true;
  };
}
