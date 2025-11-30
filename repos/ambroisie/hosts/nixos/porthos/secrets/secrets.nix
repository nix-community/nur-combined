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

  "aria/rpc-token.age".publicKeys = all;

  "backup/password.age".publicKeys = all;
  "backup/credentials.age".publicKeys = all;

  "drone/gitea.age".publicKeys = all;
  "drone/secret.age".publicKeys = all;
  "drone/ssh/private-key.age".publicKeys = all;

  "forgejo/mail-password.age" = {
    owner = "git";
    publicKeys = all;
  };

  "gitea/mail-password.age" = {
    owner = "git";
    publicKeys = all;
  };

  "lohr/secret.age" = {
    owner = "lohr";
    publicKeys = all;
  };
  "lohr/ssh-key.age" = {
    owner = "lohr";
    publicKeys = all;
  };

  "matrix/mail.age" = {
    owner = "matrix-synapse";
    publicKeys = all;
  };
  "matrix/secret.age" = {
    owner = "matrix-synapse";
    publicKeys = all;
  };

  "mealie/mail.age" = {
    publicKeys = all;
  };

  "miniflux/credentials.age".publicKeys = all;

  "monitoring/password.age" = {
    owner = "grafana";
    publicKeys = all;
  };
  "monitoring/secret-key.age" = {
    owner = "grafana";
    publicKeys = all;
  };

  "nextcloud/password.age" = {
    owner = "nextcloud";
    publicKeys = all;
  };

  "nix-cache/cache-key.age".publicKeys = all;

  "paperless/password.age".publicKeys = all;
  "paperless/secret-key.age".publicKeys = all;

  "pdf-edit/login.age".publicKeys = all;

  "podgrab/password.age".publicKeys = all;

  "pyload/credentials.age".publicKeys = all;

  "servarr/autobrr/session-secret.age".publicKeys = all;
  "servarr/cross-seed/configuration.json.age".publicKeys = all;

  "sso/auth-key.age".publicKeys = all;
  "sso/ambroisie/password-hash.age".publicKeys = all;
  "sso/ambroisie/totp-secret.age".publicKeys = all;

  "tandoor-recipes/secret-key.age".publicKeys = all;

  "transmission/credentials.age".publicKeys = all;

  "vikunja/mail.age".publicKeys = all;

  "wireguard/private-key.age".publicKeys = all;

  "woodpecker/gitea.age".publicKeys = all;
  "woodpecker/secret.age".publicKeys = all;
  "woodpecker/ssh/private-key.age".publicKeys = all;
}
