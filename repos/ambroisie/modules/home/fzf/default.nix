{ config, lib, ... }:
let
  cfg = config.my.home.fzf;
in
{
  options.my.home.fzf = with lib; {
    enable = my.mkDisableOption "fzf configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.fzf = {
      enable = true;
    };
  };
}
