# Host-specific secrets
let
  keys = import ../../../../keys;

  all = [
    # Host key
    keys.hosts.porthos
    # Allow me to modify the secrets anywhere
    keys.users.ambroisie
  ];
in
{
  "acme/dns-key.age".publicKeys = all;

  "backup/password.age".publicKeys = all;
  "backup/credentials.age".publicKeys = all;

  "drone/gitea.age".publicKeys = all;
  "drone/secret.age".publicKeys = all;
  "drone/ssh/private-key.age".publicKeys = all;

  "gitea/mail-password.age" = {
    owner = "git";
    publicKeys = all;
  };

  "lohr/secret.age".publicKeys = all;
  "lohr/ssh-key.age".publicKeys = all;

  "matrix/mail.age" = {
    owner = "matrix-synapse";
    publicKeys = all;
  };
  "matrix/secret.age" = {
    owner = "matrix-synapse";
    publicKeys = all;
  };

  "miniflux/credentials.age".publicKeys = all;

  "monitoring/password.age" = {
    owner = "grafana";
    publicKeys = all;
  };

  "nextcloud/password.age" = {
    owner = "nextcloud";
    publicKeys = all;
  };

  "paperless/password.age".publicKeys = all;
  "paperless/secret-key.age".publicKeys = all;

  "podgrab/password.age".publicKeys = all;

  "sso/auth-key.age".publicKeys = all;
  "sso/ambroisie/password-hash.age".publicKeys = all;
  "sso/ambroisie/totp-secret.age".publicKeys = all;

  "transmission/credentials.age".publicKeys = all;

  "wireguard/private-key.age".publicKeys = all;

  "woodpecker/gitea.age".publicKeys = all;
  "woodpecker/secret.age".publicKeys = all;
  "woodpecker/ssh/private-key.age".publicKeys = all;
}
