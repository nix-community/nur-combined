{ config, lib, ... }:

let
  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkIf
    ;
  cfg = config.abszero.services.darkman;

  switch-hm-specialisation = spec: ''
    hm_gens=$(nix-store -q --referrers ~/.local/state/nix/profiles/home-manager)
    $(find $hm_gens -maxdepth 1 -type d -name specialisation)/${spec}/activate
  '';
in

{
  options.abszero.services.darkman = {
    enable = mkEnableOption "darkman day/night command scheduler";
    lightSpecialisation = mkOption {
      type = types.nonEmptyStr;
    };
    darkSpecialisation = mkOption {
      type = types.nonEmptyStr;
    };
  };

  config.services.darkman = mkIf cfg.enable {
    enable = true;
    lightModeScripts.switch-hm-specialisation = switch-hm-specialisation cfg.lightSpecialisation;
    darkModeScripts.switch-hm-specialisation = switch-hm-specialisation cfg.darkSpecialisation;
    settings = {
      lat = 46;
      lng = -74;
    };
  };
}
