let
  sources = import ../nix/sources.nix { };

  nixpkgsMaster = import sources.nixpkgs-master { };
  nixpkgsUnstable = import sources.nixpkgs-unstable { };
in
{
  bees = self: super: { inherit (nixpkgsUnstable) bees; };

  brlaser = self: super: {
    brlaser = super.brlaser.overrideAttrs (oldAttrs:
      let
        rev = "9d7ddda8383bfc4d205b5e1b49de2b8bcd9137f1";
      in
      {
        version = rev;
        src = self.fetchFromGitHub {
          owner = "pdewacht";
          repo = "brlaser";
          inherit rev;
          hash = "sha256-pNkwJKdKhBO8u97GyvfxmyisaqIkzuk5UslWdaYFMLc=";
        };
      });
  };

  # https://github.com/NixOS/nixpkgs/pull/108148
  cadvisor = self: super: { inherit (nixpkgsUnstable) cadvisor; };

  deno = self: super: { inherit (nixpkgsUnstable) deno; };

  # https://github.com/NixOS/nixpkgs/pull/108736
  factorio = self: super: { inherit (nixpkgsMaster) factorio-experimental factorio-headless-experimental; };

  # https://github.com/NixOS/nixpkgs/pull/105892
  prometheus-nginx-exporter = self: super: { inherit (nixpkgsUnstable) prometheus-nginx-exporter; };
}
