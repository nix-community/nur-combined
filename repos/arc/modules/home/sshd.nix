{ config, pkgs, lib, ... }:
with lib; let
  cfg = config.services.sshd;
  authorizedKeysFile = { runCommand }: runCommand "authorized_keys" {
    source = map (pkgs.lib.asFile "authorized_key") cfg.authorizedKeys;
  } ''
    sed -s '$G' $source > $out
  '';
  activationScript = ''
    $DRY_RUN_CMD install -Dm0644 ${pkgs.callPackage authorizedKeysFile { }} ~/.ssh/authorized_keys
  '';
in {
  options.services.sshd = {
    authorizedKeys = mkOption {
      type = types.listOf (types.either types.path types.str);
      description = "SSH public keys to allow logins from";
      default = [];
    };
  };

  config.home.activation = mkIf (length cfg.authorizedKeys > 0) {
    sshdAuthorizedKeys = config.lib.dag.entryAfter ["writeBoundary"] activationScript;
  };
}
