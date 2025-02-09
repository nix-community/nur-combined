{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkDefault;
  inherit (lib.abszero.attrsets) findValue;
  cfg = config.abszero.programs.jujutsu;

  primaryEmail = findValue (_: v: v.primary) config.accounts.email.accounts;
in

{
  options.abszero.programs.jujutsu.enable = mkEnableOption "simple and powerful VCS";

  config = mkIf cfg.enable {
    abszero.programs.git.enable = true;
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = mkDefault primaryEmail.realName;
          email = mkDefault primaryEmail.address;
        };
        signing = {
          sign-all = true;
          key = mkDefault primaryEmail.address;
        };
        ui = {
          pager = "delta";
          diff.format = "git";
        };
      };
    };
  };
}
