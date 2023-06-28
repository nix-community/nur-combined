{ config, pkgs, lib, ... }:

let
  cfg = config.sane.guest;
in
{
  options = with lib; {
    sane.guest.enable = mkOption {
      default = false;
      type = types.bool;
    };
    sane.guest.authorizedKeys = mkOption {
      default = [];
      type = types.listOf types.str;
      description = ''
      list of "<key-type> <pubkey> <hostname>" keys.
      e.g.
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPU5GlsSfbaarMvDA20bxpSZGWviEzXGD8gtrIowc1pX colin@desko
      '';
    };
  };

  config = {
    users.users.guest = lib.mkIf cfg.enable {
      isNormalUser = true;
      home = "/home/guest";
      subUidRanges = [
        { startUid=200000; count=1; }
      ];
      group = "users";
      initialPassword = lib.mkDefault "";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };

    sane.persist.sys.plaintext = lib.mkIf cfg.enable [
      # intentionally allow other users to write to the guest folder
      { directory = "/home/guest"; user = "guest"; group = "users"; mode = "0775"; }
    ];
  };
}
