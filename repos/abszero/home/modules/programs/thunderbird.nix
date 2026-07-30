{ config, lib, ... }:

let
  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkIf
    ;
  cfg = config.abszero.programs.thunderbird;
in

{
  options.abszero.programs.thunderbird = {
    enable = mkEnableOption "Mozilla's mail client";
    profile = mkOption {
      type = types.nonEmptyStr;
      default = config.home.username;
    };
  };
  options.accounts.email.accounts = mkOption {
    type =
      with types;
      attrsOf (submodule {
        thunderbird.enable = mkIf cfg.enable true;
      });
  };

  config.programs.thunderbird = mkIf cfg.enable {
    enable = true;
    profiles.${cfg.profile}.isDefault = true;
  };
}
