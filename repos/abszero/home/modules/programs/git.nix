{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkDefault;
  inherit (lib.abszero.attrsets) findValue;
  cfg = config.abszero.programs.git;

  primaryEmail = findValue (_: v: v.primary) config.accounts.email.accounts;
in

{
  options.abszero.programs.git.enable = mkEnableOption "stupid content tracker";

  config.programs = mkIf cfg.enable {
    git = {
      enable = true;
      signing = {
        signByDefault = true;
        format = "openpgp";
        key = null;
      };
      settings = {
        user = {
          name = mkDefault primaryEmail.realName;
          email = mkDefault primaryEmail.address;
        };
        pull.ff = "only";
      };
    };

    difftastic = {
      enable = true;
      git.enable = true;
    };

    mergiraf.enable = true;
  };
}
