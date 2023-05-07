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
      impermanence.nixosModules.impermanence
      darkmatter-grub-theme.nixosModule
      home-manager.nixosModules.home-manager
      nur.nixosModules.nur
      hosts.${name}.hardware-configuration
    ];

    nixpkgs.overlays = [
      super.overlay
    ];

    networking.hostName = name;
    deployment.targetHost = with config.services.avahi; "${hostName}.${domainName}";
    deployment.allowLocalDeployment = true;
  };
} // (lib.mapAttrs (n: v: v.default) hosts)
