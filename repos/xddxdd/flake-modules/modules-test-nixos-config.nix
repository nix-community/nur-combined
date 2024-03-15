{
  self,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [ ./ci-outputs.nix ];

  flake = {
    nixosConfigurations = lib.genAttrs config.systems (
      system:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = (builtins.attrValues self.nixosModules) ++ [
          {
            # Minimal config to make test configuration build
            boot.loader.grub.devices = [ "/dev/vda" ];
            fileSystems."/" = {
              device = "tmpfs";
              fsType = "tmpfs";
            };

            # Add all CI packages
            environment.systemPackages = builtins.attrValues self.ciPackages."${system}";
          }
        ];
      }
    );
  };
}
