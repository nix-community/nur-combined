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
          behavior = "own";
          backend = mkIf config.programs.gpg.enable "gpg";
          key = mkDefault primaryEmail.address;
        };
        ui = {
          default-command = "log";
          diff-formatter = "difft";
        };

        merge-tools.difft.diff-args = [
          "--color=always" # Doesn't show color otherwise
          "$left"
          "$right"
        ];
      };
    };
  };
}
