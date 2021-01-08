let
  sources = import ../nix/sources.nix { };

  nixpkgsMaster = import sources.nixpkgs-master { };
  nixpkgsUnstable = import sources.nixpkgs-unstable { };

  nixpkgsFactorio = import sources.factorio { };
in
{
  bees = self: super: { inherit (nixpkgsUnstable) bees; };

  # https://github.com/NixOS/nixpkgs/pull/108148
  cadvisor = self: super: { inherit (nixpkgsUnstable) cadvisor; };

  deno = self: super: { inherit (nixpkgsUnstable) deno; };

  # https://github.com/NixOS/nixpkgs/pull/108736
  factorio = self: super: { inherit (nixpkgsFactorio) factorio-experimental factorio-headless-experimental; };

  # https://github.com/NixOS/nixpkgs/pull/105892
  prometheus-nginx-exporter = self: super: { inherit (nixpkgsUnstable) prometheus-nginx-exporter; };
}
