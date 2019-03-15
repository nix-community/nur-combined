{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.yubikey-gpg;

in

{

  options = {

    yubikey-gpg = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to configure GPG and support YubiKey devices.
        '';
        type = types.bool;
      };
    };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      gnupg
      yubikey-personalization
    ];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    security.pam.u2f.enable = true;

    services = {
      pcscd.enable = true;
      # https://raw.githubusercontent.com/Yubico/libu2f-host/af4812c/70-u2f.rules
      udev.extraRules = pkgs.stdenv.lib.strings.fileContents ./70-u2f.rules;
      udev.packages = with pkgs; [
        yubikey-personalization
      ];
    };

  };

}
