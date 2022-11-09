{ self, system ? "linux", nixpkgs, sops-nix }:
let
  inherit (nixpkgs) lib;
  inherit (self.packages.${system}) sops-install-secrets-nonblock;
in
lib.nixosSystem rec {
  inherit system;
  modules = [
    ./configuration.nix
    ./mail.nix
    ./mail-dovecot.nix
    ./mail-postfix.nix
    ./mail-rspamd.nix
    ./networking.nix
    ./hardware.nix
  ] ++
  (with self.nixosModules; [
    v2ray-next
  ]) ++
  [
    sops-nix.nixosModules.sops
    {
      _module.args = { inherit nixpkgs; };
      nix = {
        nixPath = [ "nixpkgs=${nixpkgs}" ];
        registry.eh5.flake = self;
      };
      nixpkgs.overlays = [
        self.overlays.default
        self.overlays.v2ray-rules-dat
      ];
      sops.package = sops-install-secrets-nonblock;
    }
  ];
}
