let
  sources = import ../nix/sources.nix { };
  nixpkgs = import sources.nixpkgs { };
in
{
  bees = self: super: { bees = nixpkgs.bees; };
  nix-unstable = self: super: { nixUnstable = nixpkgs.nixUnstable; };
  prometheus-nginx-exporter = import ./prometheus-nginx-exporter.nix;
}
