# SOPS configuration:
#   docs: https://github.com/Mic92/sops-nix
#
# for each new user you want to edit sops files:
# create a private age key from ssh key:
#   $ mkdir -p ~/.config/sops/age; ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt; chmod 600 ~/.config/sops/age/keys.txt
#   if the private key was password protected, then first decrypt it:
#     $ cp ~/.ssh/id_ed25519 /tmp/id_ed25519
#     $ ssh-keygen -p -N "" -f /tmp/id_ed25519
#
# for each user you want to decrypt secrets:
#   $ cat ~/.ssh/id_ed25519.pub | ssh-to-age
#   add the result to .sops.yaml
#   since we specify ssh pubkeys in the nix config, you can just grep for `ssh-ed25519` here and use those instead
#
# for each host you want to decrypt secrets:
#   $ cat /etc/ssh/ssh_host_keys/ssh_host_ed25519_key.pub | ssh-to-age
#   add the result to .sops.yaml
#   $ find secrets -type f -exec sops updatekeys -y '{}' ';'
#
# to create a new secret:
#   $ sops secrets/example.yaml
#   control access below (sops.secret.<x>.owner = ...)
#
# to read a secret:
#   $ cat /run/secrets/example_key

{ config, lib, sane-lib, ... }:

let
  secretsForHost = host: let
    extraAttrsForPath = path: lib.optionalAttrs (sane-lib.path.isChild "guest" path && builtins.hasAttr "guest" config.users.users) {
      owner = "guest";
    };
    secretsInSrc = (
      if builtins.pathExists ../../secrets/${host} then
        sane-lib.enumerateFilePaths ../../secrets/${host}
      else
        []
    );
  in sane-lib.joinAttrsets (
    map
      (path: lib.optionalAttrs (lib.hasSuffix ".bin" path) (sane-lib.nameValueToAttrs {
        name = lib.removeSuffix ".bin" path;
        value = {
          sopsFile = ../../secrets/${host}/${path};
          format = "binary";
        } // (extraAttrsForPath path);
      }))
      secretsInSrc
  );
in
{

  # sops.age.sshKeyPaths = [ "/home/colin/.ssh/id_ed25519_dec" ];
  sops.gnupg.sshKeyPaths = [];  # disable RSA key import
  # This is using an age key that is expected to already be in the filesystem
  # sops.age.keyFile = "/home/colin/.ssh/age.pub";
  # sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  # This will generate a new key if the key specified above does not exist
  # sops.age.generateKey = true;
  # This is the actual specification of the secrets.
  # sops.secrets.example_key = {
  #   owner = config.users.users.colin.name;
  # };
  # sops.secrets."myservice/my_subdir/my_secret" = {};

  sops.secrets = lib.mkMerge [
    (secretsForHost "common")
    (secretsForHost config.networking.hostName)
    {
      "jackett_apikey".owner = config.users.users.colin.name;
      "mx-sanebot-env".owner = config.users.users.colin.name;
      "rsync-net-env".owner = config.users.users.colin.name;
      "rsync-net-id_ed25519".owner = config.users.users.colin.name;
      "transmission_passwd".owner = config.users.users.colin.name;
    }
  ];
}


