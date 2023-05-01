{ config, lib, ... }:
let
  cfg = config.my.home.fzf;
in
{
  options.my.home.fzf = with lib; {
    enable = my.mkDisableOption "fzf configuration";
  };

  config = {
    programs.fzf = {
      enable = true;
    };
  };
}
