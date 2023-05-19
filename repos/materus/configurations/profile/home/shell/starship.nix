{ config, pkgs, lib, materusFlake, materusPkgs, ... }:
let
  profile = config.materus.profile;
  cfg = config.materus.profile.starship;
in
{
  options.materus.profile.starship.enable = materusPkgs.lib.mkBoolOpt (profile.zsh.enable || profile.bash.enable || profile.fish.enable) "Enable materus fish config";

  config = lib.mkIf cfg.enable {
    programs.starship.enable = lib.mkDefault cfg.enable;

    programs.starship.settings = lib.mkDefault { };

  };
}
