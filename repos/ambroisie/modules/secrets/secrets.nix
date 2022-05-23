let
  # FIXME: read them from directories
  ambroisie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIVd6Oh08iUNb1vTULbxGpevnh++wxsWW9wqhaDryIq ambroisie@agenix";
  users = [ ambroisie ];

  porthos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGzznQ3LSmBYHx6fXthgMDiTcU5i/Nvj020SbmhzAFb root@porthos";
  machines = [ porthos ];

  all = users ++ machines;
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
  "matrix/secret.age".publicKeys = all;

  "miniflux/credentials.age".publicKeys = all;

  "monitoring/password.age" = {
    owner = "grafana";
    publicKeys = all;
  };

  "nextcloud/password.age" = {
    # Must be readable by the service
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

  "users/ambroisie/hashed-password.age".publicKeys = all;
  "users/root/hashed-password.age".publicKeys = all;

  "wireguard/aramis/private-key.age".publicKeys = all;
  "wireguard/milady/private-key.age".publicKeys = all;
  "wireguard/porthos/private-key.age".publicKeys = all;
  "wireguard/richelieu/private-key.age".publicKeys = all;
}
