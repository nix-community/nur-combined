{ ... }:

{
  imports = [
    ./vaultwarden.nix
    ./borg-backup.nix
    ./fail2ban.nix
    ./fava.nix
    ./gitea
    ./jellyfin.nix
    ./lohr.nix
    ./matrix.nix
    ./media.nix
    ./miniflux.nix
    ./monitoring.nix
    ./navidrome.nix
    ./nextcloud.nix
    ./nginx.nix
    ./nuage.nix
    ./paperless.nix
    ./pipewire.nix
    ./postgresql-backup.nix
    ./postgresql.nix
    ./prololo.nix
    ./restic-backup.nix
    ./tailscale.nix
    ./tgv.nix
    ./transmission.nix
  ];
}
