{ config, pkgs, lib, ... }:
with lib; let
  cfg = config.services.sshd;
  authorizedKeysFile = pkgs.writeText "authorized_keys" (concatStringsSep "\n" cfg.authorizedKeys);
  activationScript = ''
    $DRY_RUN_CMD install -Dm0644 ${authorizedKeysFile} ~/.ssh/authorized_keys
  '';
in {
  options.services.sshd = {
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      description = "SSH public keys to allow logins from";
      default = [];
    };
  };

  config.home.activation = mkIf (length cfg.authorizedKeys > 0) {
    sshdAuthorizedKeys = config.lib.dag.entryAfter ["writeBoundary"] activationScript;
  };
}
