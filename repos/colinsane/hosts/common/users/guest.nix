{ config, pkgs, lib, ... }:

let
  cfg = config.sane.guest;
in
{
  options = with lib; {
    sane.guest.enable = mkEnableOption "enable guest account, accessible by select authorized ssh keys";
  };

  config = lib.mkIf cfg.enable {
    users.users.guest = {
      isNormalUser = true;
      home = "/home/guest";
      subUidRanges = [
        { startUid=200000; count=1; }
      ];
      group = "users";
      initialPassword = lib.mkDefault "";
      shell = pkgs.zsh;
    };

    sane.users.guest.fs.".ssh/authorized_keys".symlink.target = config.sops.secrets."guest/authorized_keys".path or "/dev/null";

    sane.persist.sys.byStore.plaintext = lib.mkIf cfg.enable [
      # intentionally allow other users to write to the guest folder
      { path = "/home/guest"; user = "guest"; group = "users"; mode = "0775"; }
    ];
  };
}
