{ config, lib, ... }:

let
  inherit (lib) types mkOption mkEnableOption mkIf attrNames genAttrs const;
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

  config = mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      profiles.${cfg.profile}.isDefault = true;
    };
    # TODO: Configure email when chat and calendar can be configured
    accounts.email.accounts = genAttrs
      (attrNames config.abszero.emails)
      (const { thunderbird.enable = false; });
  };
}
