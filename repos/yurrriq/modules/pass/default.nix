{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.pass;

in

{

  options = {

    programs.pass = {

      enable = mkOption {
        default = false;
        description = ''
          Whether to configure pass.
        '';
        type = types.bool;
      };

      git-helper = mkOption {
        default = false;
        description = ''
          Whether to install pass-git-helper.
        '';
        type = types.bool;
      };

      otp = mkOption {
        default = false;
        description = ''
          Whether to install pass-otp.
        '';
        type = types.bool;
      };

      tomb = mkOption {
        default = config.programs.tomb.enable;
        description = ''
          Whether to install pass-tomb.
        '';
        type = types.bool;
      };

    };

  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.pass.withExtensions (exts:
        optional cfg.otp exts.pass-otp ++
        optional cfg.tomb exts.pass-tomb
      ))
    ] ++ optional cfg.git-helper pkgs.gitAndTools.pass-git-helper;
  };

}

