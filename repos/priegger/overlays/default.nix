let
  sources = import ../nix/sources.nix { };

  nixpkgsUnstable = import sources.nixpkgs-unstable { };
in
{
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

  cadvisor = self: super: { inherit (nixpkgsUnstable) cadvisor; };

  prometheus-nginx-exporter = self: super: { inherit (nixpkgsUnstable) prometheus-nginx-exporter; };

  prometheus-pushgateway = self: super: { inherit (nixpkgsUnstable) prometheus-pushgateway; };
}
