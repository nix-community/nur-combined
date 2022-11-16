{ self, system ? "linux", nixpkgs, sops-nix }:
let
  inherit (nixpkgs) lib;
  inherit (self.packages.${system}) sops-install-secrets-nonblock;
in
lib.nixosSystem rec {
  inherit system;
  modules = [
    ./configuration.nix
    ./fail2ban.nix
    ./services.nix
    ./ldap.nix
    ./mail.nix
    ./mail-dovecot.nix
    ./mail-postfix.nix
    ./mail-rspamd.nix
    ./mail-sogo.nix
    ./mail-stalwart.nix
    ./networking.nix
    ./hardware.nix
  ] ++ [
    self.nixosModules.default
    sops-nix.nixosModules.sops
    {
      _module.args = { inherit nixpkgs; };
      nix = {
        nixPath = [ "nixpkgs=${nixpkgs}" ];
        registry.eh5.flake = self;
      };
      nixpkgs.overlays = [
        self.overlays.default
      ];
      sops.package = sops-install-secrets-nonblock;
    }
  ];
}
