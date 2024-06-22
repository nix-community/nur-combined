{ config, pkgs, lib, ... }:
with lib; let
  cfg = config.services.sshd;
  authorizedKeysFiles = partition (hasPrefix "/") cfg.authorizedKeys;
  authorizedKeysFile = pkgs.writeText "authorized_keys" (concatMapStrings (key: key + "\n") authorizedKeysFiles.wrong);
  activationScript = ''
    run install -Dm0644 ${authorizedKeysFile} ~/.ssh/authorized_keys
  '' + optionalString (authorizedKeysFiles.right != [ ]) ''
    if [[ ! -v DRY_RUN ]]; then
      for _sshKeyFile in ${escapeShellArgs authorizedKeysFiles.right}; do
        printf '%s\n' "$(cat $_sshKeyFile)" >> ~/.ssh/authorized_keys
      done
    fi
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
