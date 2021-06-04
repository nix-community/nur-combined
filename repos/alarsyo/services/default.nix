{ ... }:

{
  imports = [
    ./bitwarden_rs.nix
    ./borg-backup.nix
    ./fail2ban.nix
    ./gitea
    ./jellyfin.nix
    ./lohr.nix
    ./matrix.nix
    ./media.nix
    ./miniflux.nix
    ./monitoring.nix
    ./nextcloud.nix
    ./nginx.nix
    ./pipewire.nix
    ./postgresql-backup.nix
    ./postgresql.nix
    ./tgv.nix
    ./transmission.nix
    ./wireguard.nix
  ];
}
