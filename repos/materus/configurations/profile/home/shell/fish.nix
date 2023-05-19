{ config, pkgs, lib, materusFlake, materusPkgs, ... }:
let 
cfg = config.materus.profile.fish;
in
{
  options.materus.profile.fish.enable = materusPkgs.lib.mkBoolOpt config.materus.profile.enableTerminalExtra "Enable materus fish config";
  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = lib.mkDefault true;
    };
  };
}