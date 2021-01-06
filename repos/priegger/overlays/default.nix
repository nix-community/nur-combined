let
  sources = import ../nix/sources.nix { };
  nixpkgs = import sources.nixpkgs { };
in
{
  bees = self: super: { inherit (nixpkgs) bees; };

  # https://github.com/NixOS/nixpkgs/pull/108148
  cadvisor = self: super: { inherit (nixpkgs) cadvisor; };

  deno = self: super: { inherit (nixpkgs) deno; };

  # https://github.com/NixOS/nixpkgs/pull/105892
  prometheus-nginx-exporter = self: super: { inherit (nixpkgs) prometheus-nginx-exporter; };
}
