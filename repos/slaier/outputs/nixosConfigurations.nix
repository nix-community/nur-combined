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
    ({ config, ... }: {
      _module.args = {
        inherit inputs;
      };

      nixpkgs.overlays = [
        super.overlay
        inputs.bluetooth-player.overlays."${config.nixpkgs.hostPlatform.system}".default
        (final: prev: {
          rocmPackages_5 = inputs.nixpkgs-2411.legacyPackages.${config.nixpkgs.hostPlatform.system}.rocmPackages_5;
        })
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = [
          sops-nix.homeManagerModules.sops
        ];
      };

      networking.hostName = hostName;
    })
  ];
})
