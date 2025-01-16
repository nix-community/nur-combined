let
  alarsyo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3rrF3VSWI4n4cpguvlmLAaU3uftuX4AVV/39S/8GO9 alarsyo@thinkpad";
  users = [alarsyo];

  boreal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAagal1aqZh52wEmgsw7fkCzO41o4Cx+nV4wJGZuX1RP root@boreal";
  hades = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMxw8CtKUPAiPdKDEnuS7UyRrZN5BkUwsy5UPVF8V+lt root@hades";
  talos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMBYcmL9HZJ9SqB9OJwQ0Nt6ZbvHZTS+fzM8A6D5MPZs root@talos";
  thanatos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID8JEAWk/8iSl8fN6/f76JkmVFwtyixTpLol4zSVsnVw root@thanatos";

  machines = [boreal hades talos thanatos];

  all = users ++ machines;
in {
  "gandi/api-key.age".publicKeys = [alarsyo hades];

  "gitlab-runner/hades-runner-env.age".publicKeys = [alarsyo hades];
  "gitlab-runner/hades-nix-runner-env.age".publicKeys = [alarsyo hades];
  "gitlab-runner/thanatos-runner-env.age".publicKeys = [alarsyo thanatos];
  "gitlab-runner/thanatos-nix-runner-env.age".publicKeys = [alarsyo thanatos];

  "lohr/shared-secret.age".publicKeys = [alarsyo hades];

  "matrix-synapse/secret-config.age".publicKeys = [alarsyo hades];

  "microbin/secret-config.age".publicKeys = [alarsyo hades];

  "miniflux/admin-credentials.age".publicKeys = [alarsyo hades];

  "nextcloud/admin-pass.age".publicKeys = [alarsyo hades];

  "ovh/credentials.age".publicKeys = [alarsyo hades];

  "paperless/admin-password.age".publicKeys = [alarsyo hades];
  "paperless/secret-key.age".publicKeys = [alarsyo hades];

  "pleroma/pleroma-config.age".publicKeys = [alarsyo hades];

  "restic-backup/boreal-password.age".publicKeys = [alarsyo boreal];
  "restic-backup/boreal-credentials.age".publicKeys = [alarsyo boreal];
  "restic-backup/hades-password.age".publicKeys = [alarsyo hades];
  "restic-backup/hades-credentials.age".publicKeys = [alarsyo hades];
  "restic-backup/talos-password.age".publicKeys = [alarsyo talos];
  "restic-backup/talos-credentials.age".publicKeys = [alarsyo talos];

  "users/root-hashed-password.age".publicKeys = machines ++ [alarsyo];
  "users/alarsyo-hashed-password.age".publicKeys = machines ++ [alarsyo];
}
