{ super, lib, inputs, ... }:
with lib;
flip mapAttrs super.hosts (hostName: host:
nixosSystem {
  modules = with inputs; [
    darkmatter-grub-theme.nixosModule
    disko.nixosModules.disko
    home-manager.nixosModules.home-manager
    impermanence.nixosModules.impermanence
    nur.modules.nixos.default
    sops-nix.nixosModules.sops
    host.default
    host.hardware-configuration
    {
      _module.args = {
        inherit inputs;
      };

      nixpkgs.overlays = [
        super.overlay
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = [
          sops-nix.homeManagerModules.sops
        ];
      };

      networking.hostName = hostName;
    }
  ];
})
