{ config, lib, ... }:

let
  # taken from sops-nix code: checks if any secrets are needed to create /etc/shadow
  secrets-for-users = (lib.filterAttrs (_: v: v.neededForUsers) config.sops.secrets) != {};
  sops-files = config.sops.age.sshKeyPaths ++ config.sops.gnupg.sshKeyPaths ++ [ config.sops.age.keyFile ];
  keys-in-etc = builtins.any (p: builtins.substring 0 5 p == "/etc/") sops-files;
in
{
  config = lib.mkIf (secrets-for-users && keys-in-etc) {
    # secret decoding depends on keys in /etc/ (like the ssh host key), so make sure those are present.
    system.activationScripts.setupSecretsForUsers = lib.mkIf secrets-for-users {
      deps = [ "etc" ];
    };
    # TODO: we should selectively remove "users" and "groups", but keep manually specified deps?
    system.activationScripts.etc.deps = lib.mkForce [];
    assertions = builtins.concatLists (builtins.attrValues (
      builtins.mapAttrs
        (path: value: [
          {
            assertion = (builtins.substring 0 1 value.user) == "+";
            message = "non-numeric user for /etc/${path}: ${value.user} prevents early /etc linking";
          }
          {
            assertion = (builtins.substring 0 1 value.group) == "+";
            message = "non-numeric group for /etc/${path}: ${value.group} prevents early /etc linking";
          }
        ])
        config.environment.etc
    ));
  };
}
