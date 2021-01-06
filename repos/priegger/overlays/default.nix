let
  sources = import ../nix/sources.nix { };
  nixpkgs = import sources.nixpkgs { };
in
{
  bees = self: super: { bees = nixpkgs.bees; };

  # https://github.com/NixOS/nixpkgs/pull/108148
  cadvisor = self: super: { inherit (import sources.nixpkgs { }) cadvisor; };

  deno = self: super: { inherit (nixpkgs) deno; };

  # https://github.com/NixOS/nixpkgs/pull/105892
  prometheus-nginx-exporter = self: super: { inherit (import sources.nixpkgs { }) prometheus-nginx-exporter; };
}
