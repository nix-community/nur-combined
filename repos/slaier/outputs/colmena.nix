{ super, lib, inputs, hosts, modules, ... }:
{
  meta = {
    nixpkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
    };
    specialArgs = {
      inherit modules inputs;
    };
  };
  defaults = { name, config, pkgs, ... }: {
    imports = with inputs; [
      darkmatter-grub-theme.nixosModule
      home-manager.nixosModules.home-manager
      impermanence.nixosModules.impermanence
      nur.nixosModules.nur
      sops-nix.nixosModules.sops
      hosts.${name}.hardware-configuration
    ];

    nixpkgs.overlays = [
      super.overlay
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };

    networking.hostName = name;
    deployment.targetHost = with config.services.avahi; "${hostName}.${domainName}";
    deployment.allowLocalDeployment = true;
  };
} // (lib.mapAttrs (n: v: v.default) hosts)
