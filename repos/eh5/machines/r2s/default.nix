{ self, system ? "aarch64-linux", nixpkgs, sops-nix }:
let
  inherit (nixpkgs) lib;
  inherit (self.packages.${system}) sops-install-secrets-nonblock;
in
lib.nixosSystem rec {
  inherit system;
  modules = [
    ./configuration.nix
    ./tproxy.nix
    ./router.nix
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
      system.enableExtlinuxTarball = true;
      sops.package = sops-install-secrets-nonblock;
    }
  ];
}
