{
  bees = import ./bees.nix;
  nix-unstable = import ./nix-unstable.nix;
  prometheus-nginx-exporter = import ./prometheus-nginx-exporter.nix;
}
