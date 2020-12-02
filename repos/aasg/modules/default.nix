{
  dma = ./programs/dma.nix;
  dyndnsc = ./services/networking/dyndnsc.nix;
  ipfs-cluster = ./services/cluster/ipfs-cluster.nix;
  matrix-appservice-irc = ./services/networking/matrix-appservice-irc.nix;
  postgresql-base-backup = ./services/databases/postgresql-base-backup.nix;
  prometheus-bird-exporter = ./services/monitoring/prometheus/exporters/bird.nix;
  trust-dns = ./services/networking/trust-dns.nix;
  wireguard-systemd = ./services/networking/wireguard-systemd.nix;
}
